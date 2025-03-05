import SwiftUI

public extension TagTextView {
    
    /// Specifies max text length
    /// - Parameter viewId: tag number for UITextView that will be used to identify the view
    func setViewId(_ viewId: Int) -> TagTextView {
        var view = self
        view.viewId = viewId
        return view
    }

    /// Specifies whether or not this view allows rich text
    /// - Parameter enabled: If `true`, rich text editing controls will be enabled for the user
    func allowsRichText(_ enabled: Bool) -> TagTextView {
        var view = self
        view.allowRichText = enabled
        return view
    }
    
    /// Specifies max text length
    /// - Parameter lengthLimit: number of allowed simbols
    func textLengthLimit(_ length: Int?) -> TagTextView {
        var view = self
        view.textLengthLimit = length
        return view
    }

    /// Specify a placeholder text
    /// - Parameter placeholder: The placeholder text
    func placeholder(_ placeholder: String) -> TagTextView {
        self.placeholder(placeholder) { $0 }
    }

    /// Specify a placeholder with the specified configuration
    ///
    /// Example:
    ///
    ///     TextView($text)
    ///         .placeholder("placeholder") { view in
    ///             view.foregroundColor(.red)
    ///         }
    func placeholder<V: View>(_ placeholder: String, _ configure: (Text) -> V) -> TagTextView {
        var view = self
        let text = Text(placeholder)
        view.placeholderView = AnyView(configure(text))
        return view
    }

    /// Specify a custom placeholder view
    func placeholder<V: View>(_ placeholder: V) -> TagTextView {
        var view = self
        view.placeholderView = AnyView(placeholder)
        return view
    }

    /// Enables auto detection for the specified types
    /// - Parameter types: The types to detect
    func autoDetectDataTypes(_ types: UIDataDetectorTypes) -> TagTextView {
        var view = self
        view.autoDetectionTypes = types
        return view
    }

    /// Specify the foreground color for the text
    /// - Parameter color: The foreground color
    func foregroundColor(_ color: UIColor) -> TagTextView {
        var view = self
        view.foregroundColor = color
        return view
    }

    /// Specifies the capitalization style to apply to the text
    /// - Parameter style: The capitalization style
    func autocapitalization(_ style: UITextAutocapitalizationType) -> TagTextView {
        var view = self
        view.autocapitalization = style
        return view
    }

    /// Specifies the alignment of multi-line text
    /// - Parameter alignment: The text alignment
    func multilineTextAlignment(_ alignment: TextAlignment) -> TagTextView {
        var view = self
        view.multilineTextAlignment = alignment
        return view
    }

    /// Specifies the font to apply to the text
    /// - Parameter font: The font to apply
    func font(_ font: UIFont) -> TagTextView {
        var view = self
        view.font = font
        return view
    }

    /// Specifies the font weight to apply to the text
    /// - Parameter weight: The font weight to apply
    func fontWeight(_ weight: UIFont.Weight) -> TagTextView {
        let attributes: [UIFontDescriptor.AttributeName: Any] =  [UIFontDescriptor.AttributeName.traits: [
            UIFontDescriptor.TraitKey.weight: weight.rawValue
        ]]
        let newFont = UIFont(
            descriptor: font.fontDescriptor.addingAttributes(attributes),
            size: font.pointSize
        )
        return font(newFont)
    }
    
    /// Specifies  symbol for starting mentioning
    /// - Parameter symbol: The symbol to apply
    func mentionSymbol(_ symbol: String) -> TagTextView {
        var view = self
        view.mentionSymbol = symbol
        return view
    }
    
    /// Specifies  mentioning font
    /// - Parameter font: The font to apply
    func mentionFont(_ font: UIFont) -> TagTextView {
        var view = self
        view.mentionFont = font
        return view
    }
    
    /// Specifies  mentioning color
    /// - Parameter color: The color to apply
    func mentionColor(_ color: UIColor) -> TagTextView {
        var view = self
        view.mentionForegroundColor = color
        return view
    }
    
    /// Min number of symbols that will be using in tag if input field has limited length
    /// - Parameter length: number of simbols (included mention simbol: @)
    func mentionMinLength(_ length: Int) -> TagTextView {
        var view = self
        view.mentionMinLength = length
        return view
    }
    
    /// Specifies  symbol for starting hashTag
    /// - Parameter symbol: The symbol to apply
    func hashTagSymbol(_ symbol: String) -> TagTextView {
        var view = self
        view.hashTagSymbol = symbol
        return view
    }
    
    /// Specifies  HashTag font
    /// - Parameter font: The font to apply
    func hashTagFont(_ font: UIFont) -> TagTextView {
        var view = self
        view.hashTagFont = font
        return view
    }
    
    /// Specifies  HashTag color
    /// - Parameter color: The color to apply
    func hashTagColor(_ color: UIColor) -> TagTextView {
        var view = self
        view.hashTagForegroundColor = color
        return view
    }

    /// Specifies if the field should clear its content when editing begins
    /// - Parameter value: If true, the field will be cleared when it receives focus
    func clearOnInsertion(_ value: Bool) -> TagTextView {
        var view = self
        view.clearsOnInsertion = value
        return view
    }

    /// Disables auto-correct
    /// - Parameter disable: If true, autocorrection will be disabled
    func disableAutocorrection(_ disable: Bool?) -> TagTextView {
        var view = self
        if let disable {
            view.autocorrection = disable ? .no : .yes
        } else {
            view.autocorrection = .default
        }
        return view
    }

    /// Specifies whether the text can be edited
    /// - Parameter isEditable: If true, the text can be edited via the user's keyboard
    func isEditable(_ isEditable: Bool) -> TagTextView {
        var view = self
        view.isEditable = isEditable
        return view
    }

    /// Specifies whether the text can be selected
    /// - Parameter isSelectable: If true, the text can be selected
    func isSelectable(_ isSelectable: Bool) -> TagTextView {
        var view = self
        view.isSelectable = isSelectable
        return view
    }

    /// Specifies whether the field  scrolling Behavior .
    /// - Parameter isScrollingEnabled: Behavior
    func scrollingBehavior(_ scrollingBehavior: TagTextView.ScrollingBehavior) -> TagTextView {
        var view = self
        view.scrollingBehavior = scrollingBehavior
        return view
    }

    /// Specifies the type of return key to be shown during editing, for the device keyboard
    /// - Parameter style: The return key style
    func returnKey(_ style: UIReturnKeyType?) -> TagTextView {
        var view = self
        view.returnKeyType = style
        return view
    }

    /// Specifies whether the return key should auto enable/disable based on the current text
    /// - Parameter value: If true, when the text is empty the return key will be disabled
    func automaticallyEnablesReturn(_ value: Bool?) -> TagTextView {
        var view = self
        view.enablesReturnKeyAutomatically = value
        return view
    }

    /// Specifies the truncation mode for this field
    /// - Parameter mode: The truncation mode
    func truncationMode(_ mode: Text.TruncationMode) -> TagTextView {
        var view = self
        switch mode {
        case .head: view.truncationMode = .byTruncatingHead
        case .tail: view.truncationMode = .byTruncatingTail
        case .middle: view.truncationMode = .byTruncatingMiddle
        @unknown default:
            fatalError("Unknown text truncation mode")
        }
        return view
    }
}
