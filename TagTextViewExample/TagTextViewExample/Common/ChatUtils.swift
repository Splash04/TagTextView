import SwiftUI
import UIKit

enum ChatUtils {
    static func createFormatedMessage(text: String?, mentions: [TagModel]?) -> AttributedString? {
        guard let textWithAttributes = text?.nonBlank else {
            return nil
        }
        
        // Text Style
        let attributedText = NSMutableAttributedString(string: textWithAttributes)
        let textRange = NSRange(0..<attributedText.length)
        attributedText.addAttributes(Constants.Text.textAttributes, range: textRange)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.07
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .justified
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: textRange)
        
        // Hash Tag Style
        let hashTags = textWithAttributes.findHashtags()
        for hashtag in hashTags {
            if hashtag.0 != UITagTextView.Constants.Defaults.hashTagSymbol {
                attributedText.addAttributes(Constants.HashTag.textAttributes, range: hashtag.1)
            }
        }
        
        // Mentions Style
        if let mentions {
            for mention in mentions {
                attributedText.addAttributes(Constants.Mention.textAttributes, range: mention.range)
                if let objectId = (mention.data[UITagTextView.Constants.newTagPersonIdValueKey] as? String),
                   let personURL = filmCharacterDetailsUrl(objectId:  objectId) {
                    attributedText.addAttribute(.link, value: personURL, range: mention.range)
                }
            }
        }

        return AttributedString(attributedText)
    }
    
    static func filmCharacterDetailsUrl(objectId: String) -> URL? {
        let urlPath = Constants.urlPrefix + objectId
        return URL(string: urlPath)
    }
    
    static func filmCharacterId(fromUrl: URL) -> String? {
        let urlPath = fromUrl.absoluteString
        guard urlPath.contains(Constants.urlPrefix) else {
            return nil
        }
        if let characterId = urlPath.split(separator: "/").last {
            return String(characterId)
        }
        return nil
    }
}

// ******************************* MARK: - Constants

extension ChatUtils { enum Constants {} }
extension ChatUtils.Constants {

    static let urlPrefix: String = "demo://film_character/"
    
    /// Text Attributes
    enum Text {
        static let fontSize: CGFloat = 14
        static let font: UIFont = .systemFont(ofSize: fontSize)
        static let textColor: UIColor = .black
        static let textAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.font: font
        ]
    }

    /// Mention Attributes
    enum Mention {
        static let fontSize: CGFloat = 14
        static let font: UIFont = .systemFont(ofSize: fontSize)
        static let textColor: UIColor = .blue
        static let textAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.font: font
        ]
    }
    
    /// Hash Tag Attributes
    enum HashTag {
        static let fontSize: CGFloat = 14
        static let font: UIFont = .systemFont(ofSize: fontSize)
        static let textColor: UIColor = .green
        static let textAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.font: font
        ]
    }
}
