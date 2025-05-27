import Foundation

final class ChatListInteractor: ChatListInteractorProtocol {
    
    weak var presenter: ChatListInteractorOutputProtocol?
    private let currentUser: String

    init(currentUser: String) {
        self.currentUser = currentUser
    }

    func fetchChats(for user: String) {
        ChatService.shared.loadChats(for: currentUser) { [weak self] chats in
            self?.presenter?.didLoadChats(chats)
        }
    }

    func removeChat(_ chat: ChatPreview) {
        ChatService.shared.deleteChat(chat.id, for: currentUser) { [weak self] in
            self?.fetchChats(for: self?.currentUser ?? "")
        }
    }
}
