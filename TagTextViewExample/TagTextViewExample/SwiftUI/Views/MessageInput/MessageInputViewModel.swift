import Foundation
import SwiftUI
import Combine

final class MessageInputViewModel: ObservableObject {
    typealias MessageInputClosure = (MessageModel) -> Void
    
    @Published var inputText: String = .empty
    @Published var inputState: InputViewState = .base
    @Published var searchCharacterList: [FilmCharacter] = []
    @Published var selectedTagsList: [TagModel] = []
    @Published var isFirstResponder: Bool?
    
    let placeholder: String?
    
    @Published
    fileprivate var searchPersonString: String?
    fileprivate var onSendAction: MessageInputClosure?
    fileprivate let dataManager: DataManager = .shared
    fileprivate var charactersList: [FilmCharacter] = []
    fileprivate var cancellables = Set<AnyCancellable>()

    // ******************************* MARK: - Initialization and Setup
    
    init(placeholder: String?, onSendAction: MessageInputClosure?) {
        self.placeholder = placeholder
        self.onSendAction = onSendAction
        loadData()
        setupObservables()
    }
    
    fileprivate func loadData() {
        Task {
            charactersList = (try? await DataManager.shared.fetchCharacters()) ?? []
        }
    }
    
    fileprivate func setupObservables() {

        $searchPersonString
            .removeDuplicates(by: { $0 == $1 })
            .sink { [weak self] text in
                self?.searchInBD(text)
            }
            .store(in: &cancellables)
    }
    
    func sendMessageAction() {
        guard let textMessage = inputText.nonBlank else { return }
        let mentions = selectedTagsList
        let messageModel = MessageModel(
            id: Int.random(in: 0...Int.max),
            text: textMessage,
            mentions: mentions,
            date: .now
        )
        onSendAction?(messageModel)
    }
    
    func searchTags(by searchText: String?) {
        searchPersonString = searchText
    }
    
    func searchInBD(_ searchString: String?) {
        guard let searchString = searchString?.nonBlank else {
            searchCharacterList = []
            return
        }
        let normalizeSearchString = searchString.folding(options: Constants.sortOptions, locale: nil)
        
        let result = charactersList
            .filter { character -> Bool in
                character.name?.localizedCaseInsensitiveContains(searchString) == true
                || character.actor?.localizedCaseInsensitiveContains(searchString) == true
            }
            .sorted(by: { first, second in
                if let firstName = first.name,
                   firstName.folding(options: Constants.sortOptions, locale: nil).starts(with: normalizeSearchString) == true {
                    if let secondName = second.name,
                       secondName.folding(options: Constants.sortOptions, locale: nil).starts(with: normalizeSearchString) == true {
                        if firstName == secondName {
                            if let firstActor = first.actor {
                                if let secondActor = second.actor {
                                    return firstActor < secondActor
                                } else {
                                    return true
                                }
                            } else {
                                return false
                            }
                        } else {
                            return firstName < secondName
                        }
                    } else {
                        return true
                    }
                } else if second.name?.folding(options: Constants.sortOptions, locale: nil).starts(with: normalizeSearchString) == true {
                    return false
                } else if let firstActor = first.actor,
                          firstActor.folding(options: Constants.sortOptions, locale: nil).starts(with: normalizeSearchString) == true {
                    if let secondActor = second.actor,
                       secondActor.folding(options: Constants.sortOptions, locale: nil).starts(with: normalizeSearchString) == true {
                        if firstActor == secondActor {
                            if let firstName = first.name {
                                if let secondName = second.name {
                                    return firstName < secondName
                                } else {
                                    return true
                                }
                            } else {
                                return false
                            }
                        } else {
                            return firstActor < secondActor
                        }
                    } else {
                        return true
                    }
                } else if second.actor?.folding(options: Constants.sortOptions, locale: nil).starts(with: normalizeSearchString) == true {
                    return false
                } else {
                    return false
                }
            })
        searchCharacterList = result
    }
    
    func selectCharacterSuggesion(_ viewModel: FilmCharacter) {
        let userInfo: [AnyHashable: Any] = [
            UITagTextView.Constants.actionTypeKey : TagTextView.ActionType.addTagName.rawValue,
            UITagTextView.Constants.newTagNameValueKey : viewModel.name ?? .empty,
            UITagTextView.Constants.newTagPersonIdValueKey : viewModel.id
        ]
        
        TagTextView.updateViewNotification(userInfo: userInfo)
    }
    
    func clearInput() {
        inputText = .empty
        selectedTagsList = []
        searchCharacterList = []
    }
}

// ******************************* MARK: - Constants

extension MessageInputViewModel { enum Constants {} }
extension MessageInputViewModel.Constants {
    static let sortOptions: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
}
