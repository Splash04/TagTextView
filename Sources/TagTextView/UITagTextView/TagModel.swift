import Foundation

// ******************************* MARK: - TagModel

public struct TagModel: Identifiable, Equatable {
    public var id: String
    public var name: String
    public var range: NSRange
    public var data: [AnyHashable: Any]
    public var isHashTag: Bool
    public var customTextAttributes: [NSAttributedString.Key: Any]?
    
    public init(id: String = UUID().uuidString, name: String, range: NSRange, data: [AnyHashable : Any] = [:], isHashTag: Bool = false, customTextAttributes: [NSAttributedString.Key : Any]? = nil) {
        self.id = id
        self.name = name
        self.range = range
        self.data = data
        self.isHashTag = isHashTag
        self.customTextAttributes = customTextAttributes
    }

    // `data` and `customTextAttributes` contain `Any` values and cannot be auto-compared;
    // identity + structural fields are sufficient for equality checks used in diffing.
    public static func == (lhs: TagModel, rhs: TagModel) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.range == rhs.range &&
        lhs.isHashTag == rhs.isHashTag
    }
}
