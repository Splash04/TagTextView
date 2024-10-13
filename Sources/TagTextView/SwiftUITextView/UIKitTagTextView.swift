import SwiftUI

// ******************************* MARK: - UIKitTagTextView

public final class UIKitTagTextView: UITagTextView {
    public override var keyCommands: [UIKeyCommand]? {
        (super.keyCommands ?? []) + [
            UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(escape(_:)))
        ]
    }

    @objc private func escape(_ sender: Any) {
        resignFirstResponder()
    }
}
