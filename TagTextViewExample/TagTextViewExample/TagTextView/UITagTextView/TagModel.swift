import Foundation

// ******************************* MARK: - TagModel

public struct TagModel: Identifiable {
    public var id: String = UUID().uuidString
    public var name: String
    public var range: NSRange
    public var data: [AnyHashable: Any] = [:]
    public var isHashTag: Bool = false
    public var customTextAttributes: [NSAttributedString.Key: Any]?
}
