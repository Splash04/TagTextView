import Combine
import Foundation

final class ChatViewModel: ObservableObject {
    @Published
    var postList: [MessageModel] = MessageModel.previewList
    @Published
    var isNewMessageInputActive: Bool = false
    
    fileprivate var cancellables = Set<AnyCancellable>()
    
    // ******************************* MARK: - Services
    
    lazy var messageInputViewModel = MessageInputViewModel(
        placeholder: "Enter new message text",
        onSendAction: { [weak self] message in
            self?.createPost(messageModel: message)
        }
    )
    
    // ******************************* MARK: - Initialization and Setup

    
    init() {
        setupObservables()
    }
    
    // ******************************* MARK: - Private methods
    
    private func setupObservables() {
        messageInputViewModel.$inputState
            .sink { [weak self] state in
                self?.isNewMessageInputActive = state == .selected
            }
            .store(in: &cancellables)
    }
    
    // ******************************* MARK: - Actions
    
    func createPost(messageModel: MessageModel) {
        print("Create post from message: \(messageModel)")
        guard messageModel.text.hasText else {
            print("Empty message can't be sending")
            return
        }
        
        postList.append(messageModel)
        messageInputViewModel.clearInput()
    }
    
    func refresh() {
        postList.removeAll()
    }
    
}
