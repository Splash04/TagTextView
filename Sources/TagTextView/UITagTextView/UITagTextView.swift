import UIKit

open class UITagTextView: UITextView {
    
    // ******************************* MARK: - Properties
    
    open var mentionSymbol: String = Constants.Defaults.mentionSymbol
    open var hashTagSymbol: String = Constants.Defaults.hashTagSymbol
    open var textViewAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.foregroundColor: Constants.Defaults.textColor,
        NSAttributedString.Key.font: Constants.Defaults.textFont
    ]

    open var mentionTagTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.foregroundColor: Constants.Defaults.mentionColor,
        NSAttributedString.Key.font: Constants.Defaults.mentionFont
    ]

    open var hashTagTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.foregroundColor: Constants.Defaults.hashTagColor,
        NSAttributedString.Key.font: Constants.Defaults.hashTagFont
    ]
    
    public private(set) var arrTags: [TagModel] = []
    open var dpTagDelegate: TagTextViewDelegate?
    open var allowsHashTagUsingSpace: Bool = true
    open var textLengthLimit: Int?
    open var mentionMinLength: Int = Constants.Defaults.minMentionLength
    
    private var currentTaggingRange: NSRange?
    private var currentTaggingText: String? {
        didSet {
            if let tag = currentTaggingText, tag != oldValue {
                dpTagDelegate?.dpTagTextView(self, didChangedTagSearchString: tag, isHashTag: isHashTag)
            } else if oldValue?.hasText == true && currentTaggingText == nil {
                dpTagDelegate?.dpTagTextView(self, didChangedTagSearchString: "", isHashTag: isHashTag)
            }
        }
    }

    private var tagRegex: NSRegularExpression {
        (try? NSRegularExpression(pattern: "(\(mentionSymbol)|\(hashTagSymbol))([^\\s\\K]+)"))!
    }

    private var isHashTag = false
    private var tapGesture = UITapGestureRecognizer()
    
    // ******************************* MARK: - Initialization and Setup
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
}

// ******************************* MARK: - Public methods

public extension UITagTextView {
    func addTag(allText: String? = nil, tagText: String, id: String = UUID().uuidString, data: [AnyHashable: Any] = [:], customTextAttributes: [NSAttributedString.Key: Any]? = nil, isAppendSpace: Bool = true) {
        guard let range = currentTaggingRange else { return }
        guard let allText = (allText == nil ? text : allText) else { return }
        
        let origin = (allText as NSString).substring(with: range)
        let tag = isHashTag ? hashTagSymbol.appending(tagText) : mentionSymbol.appending(tagText)
        let replace = isAppendSpace ? tag.appending(" ") : tag
        
        let newText: String
        let newTagRange: NSRange
        if let textLengthLimit { // If limit enabled -> check reult text length
            let resultTextLength =
            allText.utf16.count // all text in TextField
            - origin.utf16.count // entered part of the tag
            + replace.utf16.count // full tag text length
            
            if resultTextLength > textLengthLimit { // result text with tag will exceed limit -> cut tag text to be in the limit
                let availableTagLength =
                textLengthLimit
                - (allText.utf16.count - origin.utf16.count) // text in TextView without entered sumbols of the tag
                
                let endIndex = String.Index(utf16Offset: availableTagLength, in: tag)
                let newTag = String(tag[..<endIndex])
                
                newText = (allText as NSString).replacingCharacters(in: range, with: newTag)
                newTagRange = NSRange(location: range.location, length: newTag.utf16.count)
            } else {
                newText = (allText as NSString).replacingCharacters(in: range, with: replace)
                newTagRange = NSRange(location: range.location, length: tag.utf16.count)
            }
        } else {
            newText = (allText as NSString).replacingCharacters(in: range, with: replace)
            newTagRange = NSRange(location: range.location, length: tag.utf16.count)
        }
        
        let dpTag = TagModel(id: id, name: tagText, range: newTagRange, data: data, isHashTag: isHashTag, customTextAttributes: customTextAttributes)
        arrTags.append(dpTag)
        for i in 0..<arrTags.count - 1 {
            var location = arrTags[i].range.location
            let length = arrTags[i].range.length
            if location > newTagRange.location {
                location += replace.count - origin.count
                arrTags[i].range = NSRange(location: location, length: length)
            }
        }
        
        text = newText
        updateAttributeText(selectedLocation: range.location + replace.count)
        dpTagDelegate?.dpTagTextView(self, didInsertTag: dpTag)
        dpTagDelegate?.dpTagTextView(self, didChangedTags: arrTags)
        isHashTag = false
    }
    
    func setTagDetection(_ isTagDetection: Bool, isEditable: Bool = false, isSelectable: Bool = false) {
        self.removeGestureRecognizer(tapGesture)
        if isTagDetection {
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnTextView(_:)))
            tapGesture.delegate = self
            self.addGestureRecognizer(tapGesture)
            self.isEditable = isEditable
            self.isSelectable = isSelectable
        } else {
            self.isEditable = true
            self.isSelectable = true
        }
    }
    
    func setText(_ text: String?, arrTags: [TagModel]) {
        self.text = text
        self.arrTags = arrTags
        updateAttributeText(selectedLocation: -1)
    }
    
    func setTag(_ arrTag: TagModel) {
        setTags([arrTag])
    }
    
    func setTags(_ arrTags: [TagModel]) {
        self.arrTags = arrTags
        updateAttributeText(selectedLocation: -1)
    }
    
    func addTag(_ arrTag: TagModel) {
        addTags([arrTag])
    }
    
    func addTags(_ arrTags: [TagModel]) {
        self.arrTags.append(contentsOf: arrTags)
        updateAttributeText(selectedLocation: -1)
    }

    /// This will remove all the previously cached tags. Always use this function to clear the textfields with actions
    func clearText() {
        self.text = ""
        self.arrTags.removeAll()
    }
    
    func recalculateAttributes() {
        updateAttributeText(selectedLocation: selectedRange.location)
    }
}

// ******************************* MARK: - Private methods

private extension UITagTextView {
    
    func setup() {
        delegate = self
    }
    
    @objc final func tapOnTextView(_ recognizer: UITapGestureRecognizer) {
    
        guard let textView = recognizer.view as? UITextView else {
            return
        }
        
        var location: CGPoint = recognizer.location(in: textView)
        location.x -= textView.textContainerInset.left
        location.y -= textView.textContainerInset.top
        
        let charIndex = textView.layoutManager.characterIndex(for: location, in: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        guard charIndex < textView.textStorage.length - 1 else {
            return
        }
        
        if let selectedTag = arrTags.first(where: { tag in
            tag.range.location <= charIndex && tag.range.location + tag.range.length > charIndex
        }) {
            dpTagDelegate?.dpTagTextView(self, didSelectTag: selectedTag)
        }
    }
    
    func matchedData(taggingCharacters: [Character], selectedLocation: Int, taggingText: String) -> (NSRange?, String?) {
        var matchedRange: NSRange?
        var matchedString: String?
        let tag = String(taggingCharacters.reversed())
        let textRange = NSRange(location: selectedLocation - tag.count, length: tag.count)
        
        guard tag == mentionSymbol || tag == hashTagSymbol else {
            let matched = tagRegex.matches(in: taggingText, options: .reportCompletion, range: textRange)
            if let range = matched.last?.range {
                matchedRange = range
                matchedString = (taggingText as NSString).substring(with: range).replacingOccurrences(of: isHashTag ? hashTagSymbol : mentionSymbol, with: "")
            }
            return (matchedRange, matchedString)
        }
        
        matchedRange = nil // textRange
        matchedString = nil // isHashTag ? hashTag : symbol
        return (matchedRange, matchedString)
    }
    
    func tagging(textView: UITextView) {
        let selectedLocation = textView.selectedRange.location
        let taggingText: String
        if let text = textView.text.nonBlank as? NSString, text.length >= selectedLocation {
            taggingText = text.substring(with: NSRange(location: 0, length: selectedLocation))
        } else {
            taggingText = String()
        }
        let space: Character = " "
        let lineBrak: Character = "\n"
        var tagable: Bool = false
        var characters: [Character] = []
        
        for char in Array(taggingText).reversed() {
            if char == mentionSymbol.first {
                characters.append(char)
                isHashTag = false
                tagable = true
                break
            } else if char == hashTagSymbol.first {
                characters.append(char)
                isHashTag = true
                tagable = true
                break
            } else if char == space || char == lineBrak {
                tagable = false
                break
            }
            characters.append(char)
        }
        
        guard tagable, !isHashTag else {
            currentTaggingRange = nil
            currentTaggingText = nil
            return
        }
        
        let isTaggingAvailable: Bool
        if let textLengthLimit { // If limit configured
            let availableTextLength = textLengthLimit - text.utf16.count
            let tagTextLength = characters.count
            if availableTextLength >= mentionMinLength ||
                tagTextLength >= mentionMinLength { // If min number of characters for tag is already reached -> just enable tagging
                isTaggingAvailable = true
            } else {
                let minNeededLength = mentionMinLength - tagTextLength
                if (text.utf16.count + minNeededLength) > textLengthLimit { // If current text length + needed space for tag is more then limit -> disable tagging
                    isTaggingAvailable = false
                } else {
                    isTaggingAvailable = true
                }
            }
        } else {
            isTaggingAvailable = true
        }
        
        guard isTaggingAvailable else {
            currentTaggingRange = nil
            currentTaggingText = nil
            return
        }
        
        let data = matchedData(taggingCharacters: characters, selectedLocation: selectedLocation, taggingText: taggingText)
        if let textLengthLimit,
           let newTagLocation = data.0?.location,
           let existingTag = arrTags.first(where: { $0.range.location == newTagLocation }),
           (existingTag.range.location + existingTag.range.length) == textLengthLimit,
           let newTagText = data.1,
           existingTag.name.hasPrefix(newTagText) {
            currentTaggingRange = nil
            currentTaggingText = nil
        } else {
            currentTaggingRange = data.0
            currentTaggingText = data.1
        }
    }
    
    func updateAttributeText(selectedLocation: Int) {
        guard let text else { return }
        if text.isEmpty { arrTags.removeAll() }
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttributes(textViewAttributes, range: NSRange(location: 0, length: text.utf16.count))
        for dpTag in arrTags {
            guard let customTextAttributes = dpTag.customTextAttributes else {
                if attributedString.length >= (dpTag.range.location + dpTag.range.length) {
                    attributedString.addAttributes(dpTag.isHashTag ? hashTagTextAttributes : mentionTagTextAttributes, range: dpTag.range)
                }
                continue
            }
            attributedString.addAttributes(customTextAttributes, range: dpTag.range)
        }
        // find hashtags
        
        let hashtags = text.findHashtags()
        for hashtag in hashtags {
            if hashtag.0 != hashTagSymbol {
                attributedString.addAttributes(hashTagTextAttributes, range: hashtag.1)
            }
        }
         
        attributedText = attributedString
    
        selectedRange = NSRange(location: selectedLocation, length: 0)
    }
    
    func fixedWhenMarketTextUnmatch() {
        guard let text else { return }
        var result: [TagModel] = []
        let mentions = text.findMentions()
        var sortedMentions = mentions.sorted {
            $0.1.location < $1.1.location
        }
        while !sortedMentions.isEmpty {
            let mention = sortedMentions[0]
            if let firstIndex = arrTags.firstIndex(where: { [mention] in
                mention.0 == mentionSymbol.appending($0.name)
            }) {
                var existingTag = arrTags[firstIndex]
                let updatedRange = NSRange(
                    location: mention.1.location,
                    length: existingTag.range.length
                )
                existingTag.range = updatedRange
                result.append(existingTag)
                arrTags.remove(at: firstIndex)
            }
            sortedMentions.remove(at: 0)
        }
        arrTags = result
    }
    
    func updateArrTags(range: NSRange, textCount: Int) {
        for i in 0..<arrTags.count {
            var location = arrTags[i].range.location
            let length = arrTags[i].range.length
            if location >= range.location {
                if range.length > 0 {
                    if textCount > 1 {
                        location += textCount - range.length
                    } else {
                        location -= range.length
                    }
                } else {
                    location += textCount
                }
                arrTags[i].range = NSRange(location: location, length: length)
            }
        }
        
        currentTaggingText = nil
        dpTagDelegate?.dpTagTextView(self, didChangedTags: arrTags)
    }
    
    func addHashTagWithSpace(_ replacementText: String, _ range: NSRange) {
        if isHashTag && replacementText == " " && allowsHashTagUsingSpace {
            let selectedLocation = selectedRange.location
            let newText = (text as NSString).replacingCharacters(in: range, with: replacementText)
            let taggingText = (newText as NSString).substring(with: NSRange(location: 0, length: selectedLocation + 1))
            if let tag = taggingText.sliceMultipleTimes(from: hashTagSymbol, to: " ").last {
                addTag(allText: newText, tagText: tag, isAppendSpace: false)
            }
        }
    }
}

// ******************************* MARK: - UITextViewDelegate

extension UITagTextView: UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        tagging(textView: textView)
        updateAttributeText(selectedLocation: textView.selectedRange.location)
        dpTagDelegate?.textViewDidChange(self)
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        tagging(textView: textView)
        dpTagDelegate?.textViewDidChangeSelection(self)
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let textLengthLimit, textLengthLimit >= 0 {
            let currentText = textView.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let changedText = currentText.replacingCharacters(in: stringRange, with: text)
            guard changedText.count <= textLengthLimit else { return false }
        }
        
        if text.isEmpty {
            // check tag in list. if in list, we will replace mention or hashtag and remove from list
            if let currentTag = arrTags.first(where: { $0.range.location <= range.location && $0.range.location + $0.range.length > range.location
            }) {
                let currentText = textView.text ?? ""
                arrTags.removeAll {
                    $0.range.location <= range.location && $0.range.location + $0.range.length > range.location
                }
                let result = (currentText as NSString).replacingCharacters(in: currentTag.range, with: " ")
                let attributedString = NSMutableAttributedString(string: result)
                attributedString.addAttributes(textViewAttributes, range: NSRange(location: 0, length: result.utf16.count))
                textView.attributedText = attributedString
                self.currentTaggingText = nil
                currentTaggingRange = nil
                selectedRange = NSRange(location: currentTag.range.location + 1, length: 0)
                updateArrTags(range: currentTag.range, textCount: text.utf16.count)
                return true
            }
        }
        // when add character to current tag, remove current tag
        if text.hasText {
            // check tag in list. if in list, we will replace mention or hashtag and remove from list
            if arrTags.contains(where: { $0.range.location < range.location && $0.range.location + $0.range.length > range.location
            }) {
                arrTags.removeAll {
                    $0.range.location < range.location && $0.range.location + $0.range.length > range.location
                }
                self.currentTaggingText = nil
                currentTaggingRange = nil
                updateArrTags(range: range, textCount: text.utf16.count)
                return true
            }
        }
        
        updateArrTags(range: range, textCount: text.utf16.count)
        return dpTagDelegate?.textView(self, shouldChangeTextIn: range, replacementText: text) ?? true
    }
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        dpTagDelegate?.textViewShouldBeginEditing(self) ?? true
    }
    
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        dpTagDelegate?.textViewShouldEndEditing(self) ?? true
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        dpTagDelegate?.textViewDidBeginEditing(self)
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        dpTagDelegate?.textViewDidEndEditing(self)
    }
    
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        dpTagDelegate?.textView(self, shouldInteractWith: URL, in: characterRange, interaction: interaction) ?? true
    }
    
    public func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        dpTagDelegate?.textView(self, shouldInteractWith: textAttachment, in: characterRange, interaction: interaction) ?? true
    }
}

// ******************************* MARK: - UIGestureRecognizerDelegate

extension UITagTextView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

// ******************************* MARK: - Constants

public extension UITagTextView { enum Constants {} }
public extension UITagTextView.Constants {
    enum Defaults {
        public static let mentionSymbol: String = "@"
        public static let hashTagSymbol: String = "#"
        public static let textColor: UIColor = .black
        public static let textFont: UIFont = .systemFont(ofSize: 15)
        public static let mentionColor: UIColor = .purple
        public static let mentionFont: UIFont = .boldSystemFont(ofSize: 15)
        public static let hashTagColor: UIColor = .orange
        public static let hashTagFont: UIFont = .boldSystemFont(ofSize: 15)
        public static let minMentionLength: Int = 3
    }
    
    static let newTagNameValueKey: String = "new_tag_name_value"
    static let newTagPersonIdValueKey: String = "new_tag_person_id_value"
    static let newTagModelKey: String = "new_tag_model"
    static let newTagModelsListKey: String = "new_tag_models_list"
    static let newTextKey: String = "new_text"
    static let actionTypeKey: String = "action_type"
    static let viewIdKey: String = "view_id"
}
