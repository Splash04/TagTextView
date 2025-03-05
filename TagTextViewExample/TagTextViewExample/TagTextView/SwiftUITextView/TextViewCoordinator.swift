import SwiftUI

// ******************************* MARK: - Notification

// Needs to find better solution to adding tags from SwiftUI
public extension Notification.Name {
    static let addTagNotification = Notification.Name("AddTagNotification")
}

public extension TagTextView {
    
    enum ActionType: String, Equatable, Hashable {
        case addTagName = "add_tag_name"
        case addSingleTag = "add_single_tag"
        case addTagsList = "add_tags_list"
        case setTextWithTags = "set_text_with_tags"
        case setSingleTag = "set_single_tag"
        case setTagsList = "set_tags_list"
    }
    
    static func addTag(name: String, id: Int?, viewId: Int = -1) {
        var userInfo: [AnyHashable: Any] = [
            UITagTextView.Constants.viewIdKey : viewId,
            UITagTextView.Constants.actionTypeKey : ActionType.addTagName.rawValue,
            UITagTextView.Constants.newTagNameValueKey : name
        ]
        
        if let personId = id, personId >= 0 {
            userInfo[UITagTextView.Constants.newTagPersonIdValueKey] = personId
        }
        
        updateViewNotification(userInfo: userInfo)
    }
    
    static func addTag(viewModel: TagModel, viewId: Int = -1) {
        let userInfo: [AnyHashable: Any] = [
            UITagTextView.Constants.viewIdKey : viewId,
            UITagTextView.Constants.actionTypeKey : ActionType.addSingleTag.rawValue,
            UITagTextView.Constants.newTagModelKey : viewModel
        ]
        updateViewNotification(userInfo: userInfo)
    }
    
    static func addTags(list: [TagModel], viewId: Int = -1) {
        let userInfo: [AnyHashable: Any] = [
            UITagTextView.Constants.viewIdKey : viewId,
            UITagTextView.Constants.actionTypeKey : ActionType.addTagsList.rawValue,
            UITagTextView.Constants.newTagModelsListKey : list
        ]
        updateViewNotification(userInfo: userInfo)
    }
    
    static func setText(text: String, tags: [TagModel], viewId: Int = -1) {
        let userInfo: [AnyHashable: Any] = [
            UITagTextView.Constants.viewIdKey : viewId,
            UITagTextView.Constants.actionTypeKey : ActionType.setTextWithTags.rawValue,
            UITagTextView.Constants.newTextKey : text,
            UITagTextView.Constants.newTagModelsListKey : tags
        ]
        updateViewNotification(userInfo: userInfo)
    }
    
    static func setTag(viewModel: TagModel, viewId: Int = -1) {
        let userInfo: [AnyHashable: Any] = [
            UITagTextView.Constants.viewIdKey : viewId,
            UITagTextView.Constants.actionTypeKey : ActionType.setSingleTag.rawValue,
            UITagTextView.Constants.newTagModelKey : viewModel
        ]
        updateViewNotification(userInfo: userInfo)
    }
    
    static func setTags(list: [TagModel], viewId: Int = -1) {
        let userInfo: [AnyHashable: Any] = [
            UITagTextView.Constants.viewIdKey : viewId,
            UITagTextView.Constants.actionTypeKey : ActionType.setTagsList.rawValue,
            UITagTextView.Constants.newTagModelsListKey : list
        ]
        updateViewNotification(userInfo: userInfo)
    }
    
    static func updateViewNotification(userInfo: [AnyHashable: Any]) {
        NotificationCenter.default.post(
            name: Notification.Name.addTagNotification,
            object: nil,
            userInfo: userInfo
        )
    }
}

fileprivate extension TagTextView.Representable.Coordinator {
    @objc func receivedAddTagNotification(notification: NSNotification) {
        // Take Action on Notification
        guard let userInfo = notification.userInfo,
              userInfo.count > 0 else {
            return
        }
        
        if let viewId = userInfo[UITagTextView.Constants.viewIdKey] as? Int,
           viewId >= 0 {
            guard textView.tag == viewId else {
                return
            }
        }
        
        if let actionTypeKey = userInfo[UITagTextView.Constants.actionTypeKey] as? String,
           let actionType = TagTextView.ActionType(rawValue: actionTypeKey) {
            switch actionType {
            case .addTagName:
                _ = addTagName(userInfo: userInfo)
            case .addSingleTag:
                _ = addSingleTag(userInfo: userInfo)
            case .addTagsList:
                _ = addTagsList(userInfo: userInfo)
            case .setTextWithTags:
                _ = setTextWithTags(userInfo: userInfo)
            case .setSingleTag:
                _ = setSingleTag(userInfo: userInfo)
            case .setTagsList:
                _ = setTagsList(userInfo: userInfo)
            }
        }
    }
    
    func addTagName(userInfo: [AnyHashable: Any]) -> Bool {
        guard let newTagName = userInfo[UITagTextView.Constants.newTagNameValueKey] as? String else {
            return false
        }
        textView.addTag(tagText: newTagName, data: userInfo)
        return true
    }
    
    func addSingleTag(userInfo: [AnyHashable: Any]) -> Bool {
        guard let newTag = userInfo[UITagTextView.Constants.newTagModelKey] as? TagModel else {
            return false
        }
        textView.addTag(newTag)
        return true
    }
    
    func addTagsList(userInfo: [AnyHashable: Any]) -> Bool {
        guard let newTagsList = userInfo[UITagTextView.Constants.newTagModelsListKey] as? [TagModel],
              !newTagsList.isEmpty else {
            return false
        }
        textView.addTags(newTagsList)
        return true
    }
    
    func setTextWithTags(userInfo: [AnyHashable: Any]) -> Bool {
        guard let newText = userInfo[UITagTextView.Constants.newTextKey] as? String,
              let newTagsList = userInfo[UITagTextView.Constants.newTagModelsListKey] as? [TagModel],
              !newTagsList.isEmpty else {
            return false
        }
        textView.setText(newText, arrTags: newTagsList)
        return true
    }
    
    func setSingleTag(userInfo: [AnyHashable: Any]) -> Bool {
        guard let newTag = userInfo[UITagTextView.Constants.newTagModelKey] as? TagModel else {
            return false
        }
        textView.setTag(newTag)
        return true
    }
    
    func setTagsList(userInfo: [AnyHashable: Any]) -> Bool {
        guard let newTagsList = userInfo[UITagTextView.Constants.newTagModelsListKey] as? [TagModel],
              !newTagsList.isEmpty else {
            return false
        }
        textView.setTags(newTagsList)
        return true
    }
}

// ******************************* MARK: - Coordinator + TagTextViewDelegate

public extension TagTextView.Representable {
    final class Coordinator: NSObject, TagTextViewDelegate {

        let textView: UIKitTagTextView

        private var originalText: NSAttributedString = .init()
        private var text: Binding<NSAttributedString>
        private var tags: Binding<[TagModel]>
        private var calculatedHeight: Binding<CGFloat>

        var onCommit: (() -> Void)?
        var onEditingChanged: (() -> Void)?
        var shouldEditInRange: ((Range<String.Index>, String) -> Bool)?
        var onDidBeginEditing: (() -> Void)?
        var onDidEndEditing: (() -> Void)?
        
        var didChangedTagSearchString: ((String, Bool) -> Void)?
        var didInsertTag: ((TagModel) -> Void)?
        var didRemoveTag: ((TagModel) -> Void)?
        var didSelectTag: ((TagModel) -> Void)?
        var didChangedTags: (([TagModel]) -> Void)?

        init(text: Binding<NSAttributedString>,
             tags: Binding<[TagModel]>,
             viewId: Int,
             calculatedHeight: Binding<CGFloat>,
             shouldEditInRange: ((Range<String.Index>, String) -> Bool)?,
             onEditingChanged: (() -> Void)?,
             onCommit: (() -> Void)?,
             onDidBeginEditing: (() -> Void)?,
             onDidEndEditing: (() -> Void)?,
             didChangedTagSearchString: ((String, Bool) -> Void)?,
             didInsertTag: ((TagModel) -> Void)?,
             didRemoveTag: ((TagModel) -> Void)?,
             didSelectTag: ((TagModel) -> Void)?,
             didChangedTags: (([TagModel]) -> Void)?) {
            textView = UIKitTagTextView()
            textView.tag = viewId
            textView.backgroundColor = .clear
            textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

            self.text = text
            self.tags = tags
            self.calculatedHeight = calculatedHeight
            self.shouldEditInRange = shouldEditInRange
            self.onEditingChanged = onEditingChanged
            self.onCommit = onCommit
            self.onDidBeginEditing = onDidBeginEditing
            self.onDidEndEditing = onDidEndEditing
            
            self.didChangedTagSearchString = didChangedTagSearchString
            self.didInsertTag = didInsertTag
            self.didRemoveTag = didRemoveTag
            self.didSelectTag = didSelectTag
            self.didChangedTags = didChangedTags

            super.init()
            textView.dpTagDelegate = self
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.receivedAddTagNotification(notification:)),
                                                   name: Notification.Name.addTagNotification,
                                                   object: nil)
        }

        public func textViewDidBeginEditing(_ textView: UITagTextView) {
            originalText = text.wrappedValue
            onDidBeginEditing?()
        }

        public func textViewDidChange(_ textView: UITagTextView) {
            if text.wrappedValue != textView.attributedText {
                text.wrappedValue = NSAttributedString(attributedString: textView.attributedText)
            }
            recalculateHeight()
            onEditingChanged?()
        }

        public func textView(_ textView: UITagTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if onCommit != nil, text == "\n" {
                onCommit?()
                originalText = NSAttributedString(attributedString: textView.attributedText)
                textView.resignFirstResponder()
                return false
            }
            
            if let shouldEditInRange, let range = Range(range, in: textView.text) {
                return shouldEditInRange(range, text)
            }

            return true
        }

        public func textViewDidEndEditing(_ textView: UITagTextView) {
            // this check is to ensure we always commit text when we're not using a closure
            if onCommit != nil {
                originalText = NSAttributedString(attributedString: textView.attributedText)
                text.wrappedValue = originalText
            }
            onDidEndEditing?()
        }
        
        // Tag View
        
        public func dpTagTextView(_ textView: UITagTextView, didChangedTagSearchString strSearch: String, isHashTag: Bool) {
            didChangedTagSearchString?(strSearch, isHashTag)
        }
        
        public func dpTagTextView(_ textView: UITagTextView, didInsertTag tag: TagModel) {
            didInsertTag?(tag)
        }
        
        public func dpTagTextView(_ textView: UITagTextView, didRemoveTag tag: TagModel) {
            didRemoveTag?(tag)
        }
        
        public func dpTagTextView(_ textView: UITagTextView, didSelectTag tag: TagModel) {
            didSelectTag?(tag)
        }
        
        public func dpTagTextView(_ textView: UITagTextView, didChangedTags arrTags: [TagModel]) {
            text.wrappedValue = NSAttributedString(attributedString: textView.attributedText)
            tags.wrappedValue = textView.arrTags
            didChangedTags?(arrTags)
        }
    }
}

// ******************************* MARK: - Update TextView by Representable

extension TagTextView.Representable.Coordinator {

    func update(representable: TagTextView.Representable) {
        if representable.allowsRichText {
            if textView.attributedText != representable.text {
                textView.attributedText = representable.text
            }
        } else {
            if textView.attributedText.string != representable.text.string {
                textView.attributedText = representable.text
            }
        }
        
        textView.font = representable.font
        textView.adjustsFontForContentSizeCategory = true
        textView.textColor = representable.foregroundColor
        textView.autocapitalizationType = representable.autocapitalization
        textView.autocorrectionType = representable.autocorrection
        textView.isEditable = representable.isEditable
        textView.isSelectable = representable.isSelectable
        textView.isScrollEnabled = representable.scrollingBehavior.isEnable(forTextHeight: representable.calculatedHeight)
        textView.dataDetectorTypes = representable.autoDetectionTypes
        textView.allowsEditingTextAttributes = representable.allowsRichText
        textView.textLengthLimit = representable.textLengthLimit
        textView.mentionMinLength = representable.mentionMinLength
        textView.tag = representable.viewId
        
        textView.textViewAttributes = [
            NSAttributedString.Key.foregroundColor: representable.foregroundColor,
            NSAttributedString.Key.font: representable.font
        ]
        
        textView.mentionTagTextAttributes = [
            NSAttributedString.Key.foregroundColor: representable.mentionForegroundColor,
            NSAttributedString.Key.font: representable.mentionFont
        ]
        textView.mentionSymbol = representable.mentionSymbol
        
        textView.hashTagTextAttributes = [
            NSAttributedString.Key.foregroundColor: representable.hashTagForegroundColor,
            NSAttributedString.Key.font: representable.hashTagFont
        ]
        textView.hashTagSymbol = representable.hashTagSymbol

        switch representable.multilineTextAlignment {
        case .leading:
            textView.textAlignment = textView.traitCollection.layoutDirection ~= .leftToRight ? .left : .right
        case .trailing:
            textView.textAlignment = textView.traitCollection.layoutDirection ~= .leftToRight ? .right : .left
        case .center:
            textView.textAlignment = .center
        }

        if let value = representable.enablesReturnKeyAutomatically {
            textView.enablesReturnKeyAutomatically = value
        } else {
            textView.enablesReturnKeyAutomatically = onCommit == nil ? false : true
        }

        if let returnKeyType = representable.returnKeyType {
            textView.returnKeyType = returnKeyType
        } else {
            textView.returnKeyType = onCommit == nil ? .default : .done
        }
        
        textView.textContainer.lineFragmentPadding = representable.scrollingBehavior.lineFragmentPadding
        textView.textContainerInset = representable.scrollingBehavior.textContainerInset

        recalculateHeight()
        textView.setNeedsDisplay()
        textView.recalculateAttributes()
    }

    private func recalculateHeight() {
        let newSize = textView.sizeThatFits(CGSize(width: textView.frame.width, height: .greatestFiniteMagnitude))
        guard calculatedHeight.wrappedValue != newSize.height else { return }

        DispatchQueue.main.async { // call in next render cycle.
            self.calculatedHeight.wrappedValue = newSize.height
        }
    }
}
