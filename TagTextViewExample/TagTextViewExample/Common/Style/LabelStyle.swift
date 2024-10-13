import SwiftUI
import UIKit

struct LabelStyle {
    var font: UIFont
    var textColor: UIColor
}

extension UILabel {
    func configureStyle(_ style: LabelStyle) {
        textColor = style.textColor
        font = style.font
    }
}

extension Text {
    func configureStyle(_ style: LabelStyle) -> some View {
        foregroundStyle(Color(style.textColor))
            .font(Font(style.font))
    }

    init(_ text: String, style: LabelStyle) {
        self = Text(text)
            .foregroundColor(Color(style.textColor))
            .font(Font(style.font))
    }
}
