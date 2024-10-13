import SwiftUI
import UIKit

struct TextFieldStyle {
    var placeholder: LabelStyle
    var text: LabelStyle
    var cursorColor: UIColor
}

extension UITextField {
    
    func configureStyle(_ style: TextFieldStyle) {
        textColor = style.text.textColor
        font = style.text.font
        tintColor = style.cursorColor
    }
}

extension TextField {
    func configureStyle(_ style: TextFieldStyle) -> some View {
        foregroundStyle(Color(style.text.textColor))
            .font(Font(style.text.font))
            .accentColor(Color(style.cursorColor))
    }
}
