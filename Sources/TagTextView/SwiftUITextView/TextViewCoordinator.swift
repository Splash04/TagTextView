import SwiftUI

// ******************************* MARK: - Notification

// Needs to find better solution to adding tags from SwiftUI
public extension Notification.Name {
    static let addTagNotification = Notification.Name("AddTagNotification")
}

public extension TagTextView {
    static func addTag(name: String, id: Int?) {
        var userInfo: [AnyHashable: Any] = [:]
        
        userInfo[UITagTextView.Constants.newTagNameValueKey] = name
        
        if let personId = id, personId >= 0 {
            userInfo[UITagTextView.Constants.newTagPersonIdValueKey] = personId
        }
        
        addTag(userInfo: userInfo)
    }
    
    static func addTag(userInfo: [AnyHashable: Any]) {
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
        if let userInfo = notification.userInfo,
           let newTagValue = userInfo[UITagTextView.Constants.newTagNameValueKey] as? String {
            textView.addTag(tagText: newTagValue, data: userInfo)
        }
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
