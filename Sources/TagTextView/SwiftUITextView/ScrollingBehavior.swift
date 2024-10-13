import SwiftUI
import UIKit

// ******************************* MARK: - ScrollingBehavior

public extension TagTextView {
    enum ScrollingBehavior {
        case enable
        case disable
        case maxHeight(CGFloat)
    }
}

// ******************************* MARK: - ScrollingBehavior Extension

public extension TagTextView.ScrollingBehavior {
    func isEnable(forTextHeight textHeight: CGFloat) -> Bool {
        switch self {
        case .enable:
            return true
        case .disable:
            return false
        case .maxHeight(let maxValue):
            return textHeight >= maxValue ? true : false
        }
    }
    
    func viewMaxHeight(forTextHeight textHeight: CGFloat) -> CGFloat {
        switch self {
        case .enable:
            return .infinity
        case .disable:
            return textHeight
        case .maxHeight(let maxValue):
            return textHeight >= maxValue ? maxValue : textHeight
        }
    }
    
    func viewMinHeight(forTextHeight textHeight: CGFloat) -> CGFloat {
        switch self {
        case .enable:
            return 0
        case .disable:
            return textHeight
        case .maxHeight(let maxValue):
            return textHeight >= maxValue ? maxValue : textHeight
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .enable,
             .maxHeight:
            return 5
        case .disable:
            return 0
        }
    }
    
    var verticalPadding: CGFloat {
        switch self {
        case .enable,
             .maxHeight:
            return 8
        case .disable:
            return 0
        }
    }
    
    var lineFragmentPadding: CGFloat {
        switch self {
        case .enable,
             .maxHeight:
            return 5 // default
        case .disable:
            return 0
        }
    }
    
    var textContainerInset: UIEdgeInsets {
        switch self {
        case .enable,
             .maxHeight:
            return UIEdgeInsets( // .default
                top: 8,
                left: 0,
                bottom: 8,
                right: 0
            )
        case .disable:
            return .zero
        }
    }
}
