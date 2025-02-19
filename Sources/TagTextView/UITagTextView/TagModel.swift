import Foundation

// ******************************* MARK: - TagModel

public struct TagModel: Identifiable {
    public var id: String = UUID().uuidString
    public var name: String
    public var range: NSRange
    public var data: [AnyHashable: Any] = [:]
    public var isHashTag: Bool = false
    public var customTextAttributes: [NSAttributedString.Key: Any]?
    
    public init(id: String, name: String, range: NSRange, data: [AnyHashable : Any], isHashTag: Bool, customTextAttributes: [NSAttributedString.Key : Any]? = nil) {
        self.id = id
        self.name = name
        self.range = range
        self.data = data
        self.isHashTag = isHashTag
        self.customTextAttributes = customTextAttributes
    }
}
