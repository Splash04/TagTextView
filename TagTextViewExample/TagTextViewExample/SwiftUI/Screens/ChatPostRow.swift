import SwiftUI

// ******************************* MARK: - ChatPostRow

struct ChatPostRow: View {
    var viewModel: MessageModel
    var onShowFilmCharacterDetails: (String) -> Void = { _ in }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            CreatorInfoView()
            VStack(alignment: .leading, spacing: 16) {
                MessageInfoView(message: viewModel.messageAttributedString,
                                date: viewModel.date,
                                onTagClick: { characterId in
                    onShowFilmCharacterDetails(characterId)
                })
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.all, 16)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .inset(by: 0.5)
                .stroke(Color(.lightGray), lineWidth: 1)
        )
    }
}

// ******************************* MARK: - CreatorInfoView

extension ChatPostRow {
    struct CreatorInfoView: View {
        var body: some View {
            HStack(alignment: .top, spacing: 16) {
                LazyImageView(data: .network(
                    url: URL(string: "https://upload.wikimedia.org/wikipedia/commons/8/8d/JK_Rowling_1999.jpg"),
                    placeholder: UIImage(named: "person.circle"),
                    contentMode: .scaleAspectFill
                ),
                              tintColor: .lightGray,
                              backgroundColor: .blue)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(Circle())
                .frame(width: 36, height: 36)
                    
                VStack(alignment: .leading, spacing: 0) {
                    Text("Joanne Rowling")
                        .foregroundStyle(Color(.black))
                        .font(.system(size: 16).weight(.medium))
                    Text("Author • Philanthropist")
                        .foregroundStyle(Color(.darkGray))
                        .font(.system(size: 14).weight(.light))
                }
                .frame(minHeight: 36)
                Spacer()
            }
            .frame(idealHeight: 36)
        }
    }
}

// ******************************* MARK: - MessageInfoView

extension ChatPostRow {
    struct MessageInfoView: View {
        
        private static let dateFormatter: DateFormatter = {
            let result = DateFormatter()
            result.dateStyle = .medium
            result.timeStyle = .none
            return result
        }()
        
        let message: AttributedString?
        let date: Date?
        var onTagClick: ((String) -> Void)?
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                if let message {
                    Text(message)
                        .multilineTextAlignment(.leading)
                        .environment(\.openURL, OpenURLAction { url in
                            if let personId = ChatUtils.filmCharacterId(fromUrl: url) {
                                onTagClick?(personId)
                                return .handled
                            }
                            return .systemAction
                        })
                }
                Divider()
                    .overlay(Color(.lightGray))
                if let date,
                   let dateString = Self.dateFormatter.string(for: date) {
                    HStack {
                        Spacer()
                        Text(dateString)
                            .foregroundStyle(Color(.gray))
                            .font(.system(size: 12))
                            .multilineTextAlignment(.trailing)
                            .frame(width: .infinity)
                    }
                }
            }
        }
    }
}

#if DEBUG

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        Group {
            ForEach(MessageModel.previewList) { post in
                ChatPostRow(viewModel: post)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}

#endif
