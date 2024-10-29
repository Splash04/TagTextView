import SwiftUI

struct MessageInputView: View {
    
    @ObservedObject
    private(set) var viewModel: MessageInputViewModel

    init(viewModel: MessageInputViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            TagTextView(
                $viewModel.inputText,
                tags: $viewModel.selectedTagsList,
                onDidBeginEditing: {
                    viewModel.inputState = .selected
                },
                onDidEndEditing: {
                    viewModel.inputState = .base
                },
                didChangedTagSearchString: { searchString, isHashTag in
                    if !isHashTag {
                        viewModel.searchTags(by: searchString)
                    } else {
                        viewModel.searchTags(by: nil)
                    }
                }
            )
            .placeholder(viewModel.placeholder ?? .empty) {
                $0.foregroundColor(Color(viewModel.inputState.textFieldStyle.placeholder.textColor))
            }
            .foregroundColor(viewModel.inputState.textFieldStyle.text.textColor)
            .font(Constants.inputTextFont)
            .textLengthLimit(1000)
            .mentionColor(Constants.mentionColor)
            .mentionFont(Constants.inputTextFont)
            .mentionMinLength(3)
            .hashTagColor(Constants.hashTagColor)
            .hashTagFont(Constants.inputTextFont)
            .scrollingBehavior(.maxHeight(100))
            .padding(.vertical, 4)
            .padding(.horizontal, 12)
            .background {
                RoundedRectangle(cornerRadius: viewModel.inputState.cornerRadius)
                    .stroke(Color(viewModel.inputState.borderColor), lineWidth: viewModel.inputState.borderWidth)
            }
            .padding(.vertical, 0)
            
            Button(action: {
                viewModel.sendMessageAction()
            }, label: {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(Color(.white))
                    .frame(width: 22, height: 22)
                    .accessibilityAddTraits(.isImage)
                    .accessibilityLabel(Text("search_image"))
                    .padding(.all, 12)
                    .background(Color(.blue))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            })
        }
        .overlay(alignment: .bottom) {
            hintsView
        }
        .padding(.all, 16)
    }
    
    // ******************************* MARK: - Hints View
    
    @ViewBuilder
    var hintsView: some View {
        GeometryReader { _ in
            let cellSize: CGFloat = 44
            let visibleCellCount = viewModel.searchCharacterList.count > 5 ? 5 : viewModel.searchCharacterList.count
            let viewHeight = CGFloat(visibleCellCount) * cellSize
            if viewModel.searchCharacterList.count > 0 {
                List {
                    ForEach(viewModel.searchCharacterList) { character in
                        Button(action: {
                            viewModel.selectCharacterSuggesion(character)
                        }, label: {
                            VStack(spacing: 0) {
                                HStack(spacing: 8) {
                                    LazyImageView(data: character.profileImageData,
                                                  tintColor: .lightGray)
                                        .accessibilityAddTraits(.isImage)
                                        .accessibilityLabel(Text("Profile image"))
                                        .frame(width: 32, height: 32)
                                        .clipShape(Circle())
                                    VStack(alignment: .leading) {
                                        Text(character.name ?? .empty)
                                            .font(.system(size: 14))
                                            .foregroundStyle(Color(.darkGray))
                                            .multilineTextAlignment(.leading)
                                        Text(character.actor ?? .empty)
                                            .font(.system(size: 12))
                                            .foregroundStyle(Color(.lightGray))
                                            .multilineTextAlignment(.leading)
                                    }
                              
                                    Spacer()
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 16)
                                    
                                Divider()
                                    .overlay(Color(.lightGray))
                                    .frame(height: 1)
                                    .padding(.all, 0)
                            }
                        })
                        .frame(width: .infinity, height: cellSize, alignment: .leading)
                        .scaleEffect(CGSize(width: 1.0, height: -1.0))
                        .fixedSize(horizontal: false, vertical: true)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init())
                        .listStyle(.plain)
                    }
                }
                .listStyle(.plain)
                .background(Color(.white))
                .scaleEffect(CGSize(width: 1.0, height: -1.0))
                .frame(width: .infinity,
                       height: viewHeight,
                       alignment: .leading)
                .cornerRadius(12)
                .shadow(
                    color: Color(.black).opacity(0.2),
                    radius: 7.5,
                    x: 0,
                    y: 5
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .inset(by: 0.5)
                        .stroke(Color(.lightGray), lineWidth: 1)
                )
                .offset(y: -(viewHeight + 3))
            }
        }
    }
}

// ******************************* MARK: - Constants

extension MessageInputView { enum Constants {} }
extension MessageInputView.Constants {
    static let inputTextFont: UIFont = .systemFont(ofSize: 16)
    static let mentionColor: UIColor = .blue
    static let hashTagColor: UIColor = .green
}

#if DEBUG
struct MessageInputView_Previews: PreviewProvider {
    
    static let viewModel = MessageInputViewModel(
        placeholder: "Enter new message text",
        onSendAction: nil
    )
    
    static var previews: some View {
        VStack {
            Spacer()
            MessageInputView(viewModel: viewModel)
        }
    }
}
#endif
