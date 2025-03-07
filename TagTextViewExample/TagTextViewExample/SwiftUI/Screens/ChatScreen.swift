//
//  ChatScreen.swift
//  TagTextViewExample
//
//  Created by Igor Kharytaniuk on 12.10.24.
//

import SwiftUI

struct ChatScreen: ViewControllable {
    var holder: NavigationStackHolder
    
    @ObservedObject
    private(set) var viewModel: ChatViewModel

    init(holder: NavigationStackHolder, viewModel: ChatViewModel) {
        self.holder = holder
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                scrollingContent
                if viewModel.isNewMessageInputActive {
                    Color(.black)
                        .opacity(0.05)
                        .transition(.opacity)
                        .onTapGesture {
                            hideKeyboard()
                        }
                }
            }
            MessageInputView(viewModel: viewModel.messageInputViewModel)
        }
    }
    
    @ViewBuilder
    var scrollingContent: some View {
        List {
            ForEach(viewModel.postList) { item in
                ChatPostRow(
                    viewModel: item) { objectId in
                        print("Open character with id: \(objectId)")
                    }
                .listRowSeparator(.hidden)
                .buttonStyle(PlainButtonStyle())
                .listRowInsets(.init(top: 16, leading: 16, bottom: 16, trailing: 16))
            }
        }
        .listStyle(.plain)
        .refreshable {
            viewModel.refresh()
        }
    }
    
    func loadView() {
        holder.viewController?.navigationItem.title = "SwiftUI Chat"
    }
    
    func viewDidAppear(viewController: UIViewController, animated: Bool) {
        viewModel.messageInputViewModel.isFirstResponder = true
    }
    
    func viewWillDisappear(viewController: UIViewController, animated: Bool) {
        viewModel.messageInputViewModel.isFirstResponder = false
    }
}

#if DEBUG
#Preview {
    ChatScreen(
        holder: NavigationStackHolder(),
        viewModel: ChatViewModel()
    )
}
#endif
