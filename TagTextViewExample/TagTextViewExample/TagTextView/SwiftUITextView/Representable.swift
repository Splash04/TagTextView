import SwiftUI

public extension TagTextView {
    struct Representable: UIViewRepresentable {

        @Binding var text: NSAttributedString
        @Binding var tags: [TagModel]
        @Binding var calculatedHeight: CGFloat

        let foregroundColor: UIColor
        let autocapitalization: UITextAutocapitalizationType
        var multilineTextAlignment: TextAlignment
        let font: UIFont
        let returnKeyType: UIReturnKeyType?
        let clearsOnInsertion: Bool
        let autocorrection: UITextAutocorrectionType
        let truncationMode: NSLineBreakMode
        let isEditable: Bool
        let isSelectable: Bool
        let scrollingBehavior: ScrollingBehavior
        let enablesReturnKeyAutomatically: Bool?
        var autoDetectionTypes: UIDataDetectorTypes = []
        var allowsRichText: Bool
        
        let mentionSymbol: String
        let mentionForegroundColor: UIColor
        let mentionFont: UIFont
        
        let hashTagSymbol: String
        let hashTagForegroundColor: UIColor
        let hashTagFont: UIFont

        var onEditingChanged: (() -> Void)?
        var shouldEditInRange: ((Range<String.Index>, String) -> Bool)?
        var onCommit: (() -> Void)?
        var onDidBeginEditing: (() -> Void)?
        var onDidEndEditing: (() -> Void)?
        
        var didChangedTagSearchString: ((String, Bool) -> Void)?
        var didInsertTag: ((TagModel) -> Void)?
        var didRemoveTag: ((TagModel) -> Void)?
        var didSelectTag: ((TagModel) -> Void)?
        var didChangedTags: (([TagModel]) -> Void)?

        public func makeUIView(context: Context) -> UIKitTagTextView {
            context.coordinator.textView
        }

        public func updateUIView(_ view: UIKitTagTextView, context: Context) {
            context.coordinator.update(representable: self)
        }

        @discardableResult public func makeCoordinator() -> Coordinator {
            Coordinator(
                text: $text,
                tags: $tags,
                calculatedHeight: $calculatedHeight,
                shouldEditInRange: shouldEditInRange,
                onEditingChanged: onEditingChanged,
                onCommit: onCommit,
                onDidBeginEditing: onDidBeginEditing,
                onDidEndEditing: onDidEndEditing,
                didChangedTagSearchString: didChangedTagSearchString,
                didInsertTag: didInsertTag,
                didRemoveTag: didRemoveTag,
                didSelectTag: didSelectTag,
                didChangedTags: didChangedTags
            )
        }
    }
}
