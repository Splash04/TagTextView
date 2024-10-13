import Foundation

struct MessageModel: Identifiable {
    let id: Int
    let text: String
    let mentions: [TagModel]
    let date: Date
//    
//    static let empty: MessageModel = MessageModel(id: Int.random(in: Int.min...Int.max), text: .empty, mentions: [], date: .now)
}

// ******************************* MARK: - messageAttributedString

extension MessageModel {
    var messageAttributedString: AttributedString? {
        ChatUtils.createFormatedMessage(
            text: text,
            mentions: mentions
        )
    }
}

#if DEBUG

// ******************************* MARK: - SwiftUI Preview Data

extension MessageModel {
    static var previewList: [MessageModel] = [
        MessageModel(
            id: 1,
            text: "You don’t really think you’re going to be able to find all those #Horcruxes by yourself, do you? You need us, @Harry Potter.",
            mentions: [
                TagModel(name: "Harry Potter", range: NSMakeRange(110, 13))
            ],
            date: .now
        )
    ]
}

#endif
