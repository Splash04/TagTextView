import UIKit

// ******************************* MARK: - DPTagTextViewDelegate

public protocol TagTextViewDelegate: AnyObject {
    func dpTagTextView(_ textView: UITagTextView, didChangedTagSearchString strSearch: String, isHashTag: Bool)
    func dpTagTextView(_ textView: UITagTextView, didInsertTag tag: TagModel)
    func dpTagTextView(_ textView: UITagTextView, didRemoveTag tag: TagModel)
    func dpTagTextView(_ textView: UITagTextView, didSelectTag tag: TagModel)
    func dpTagTextView(_ textView: UITagTextView, didChangedTags arrTags: [TagModel])

    func textViewShouldBeginEditing(_ textView: UITagTextView) -> Bool
    func textViewShouldEndEditing(_ textView: UITagTextView) -> Bool
    func textViewDidBeginEditing(_ textView: UITagTextView)
    func textViewDidEndEditing(_ textView: UITagTextView)
    func textView(_ textView: UITagTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    func textViewDidChange(_ textView: UITagTextView)
    func textViewDidChangeSelection(_ textView: UITagTextView)
    func textView(_ textView: UITagTextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool
    func textView(_ textView: UITagTextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool
}

// ******************************* MARK: - Defaults

public extension TagTextViewDelegate {
    func dpTagTextView(_ textView: UITagTextView, didChangedTagSearchString strSearch: String, isHashTag: Bool) {}
    func dpTagTextView(_ textView: UITagTextView, didInsertTag tag: TagModel) {}
    func dpTagTextView(_ textView: UITagTextView, didRemoveTag tag: TagModel) {}
    func dpTagTextView(_ textView: UITagTextView, didSelectTag tag: TagModel) {}
    func dpTagTextView(_ textView: UITagTextView, didChangedTags arrTags: [TagModel]) {}
    
    func textViewShouldBeginEditing(_ textView: UITagTextView) -> Bool { true }
    func textViewShouldEndEditing(_ textView: UITagTextView) -> Bool { true }
    func textViewDidBeginEditing(_ textView: UITagTextView) {}
    func textViewDidEndEditing(_ textView: UITagTextView) {}
    func textView(_ textView: UITagTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool { true }
    func textViewDidChange(_ textView: UITagTextView) {}
    func textViewDidChangeSelection(_ textView: UITagTextView) {}
    func textView(_ textView: UITagTextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool { true }
    func textView(_ textView: UITagTextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool { true }
}
