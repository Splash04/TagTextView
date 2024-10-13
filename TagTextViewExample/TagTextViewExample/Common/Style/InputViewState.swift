import UIKit

// ******************************* MARK: - InputViewState

enum InputViewState: String, CaseIterable {
    case base
    case selected
    case error
}

// ******************************* MARK: - Background View

extension InputViewState {
    var borderColor: UIColor {
        switch self {
        case .base: return .darkGray
        case .error: return .red
        case .selected: return .blue
        }
    }

    var backgrounColor: UIColor { .clear }

    var cornerRadius: CGFloat { 6 }
    var borderWidth: CGFloat { 1 }
}

// ******************************* MARK: - Icon

extension InputViewState {
    var iconColor: UIColor {
        borderColor
    }
}

// ******************************* MARK: - TextField

extension InputViewState {
    private var textColor: UIColor {
        switch self {
        case .base: return .darkGray
        case .error: return .red
        case .selected: return .black
        }
    }

    private var fontSize: CGFloat { 16 }
    private var font: UIFont { .systemFont(ofSize: fontSize) }

    private var cursorColor: UIColor {
        switch self {
        case .base: return .black
        case .error: return .red
        case .selected: return .blue
        }
    }
    
    private var textFieldTextStyle: LabelStyle { LabelStyle(
        font: font,
        textColor: textColor
    )
    }
    
    private var placeholderStyle: LabelStyle { LabelStyle(
        font: font,
        textColor: .gray
    )
    }
    
    var textFieldStyle: TextFieldStyle { TextFieldStyle(
        placeholder: placeholderStyle,
        text: textFieldTextStyle,
        cursorColor: cursorColor
    )
    }
}
