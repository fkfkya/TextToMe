import Foundation

final class ChatListPresenter: ChatListPresenterProtocol, ChatListInteractorOutputProtocol {

    weak var view: ChatListViewProtocol?
    var interactor: ChatListInteractorProtocol?
    var router: ChatListRouterProtocol?

    private let currentUser: String

    init(currentUser: String) {
        self.currentUser = currentUser
    }

    func viewDidLoad() {
        interactor?.fetchChats(for: currentUser)
    }

    func didLoadChats(_ chats: [ChatPreview]) {
        view?.displayChats(chats)
    }

    func didSelectChat(_ chat: ChatPreview) {
        router?.navigateToChat(with: chat.id, currentUser: currentUser)
    }

    func didDeleteChat(_ chat: ChatPreview) {
        interactor?.removeChat(chat)
    }

    func didTapNewChat() {
        router?.navigateToCreateChat(currentUser: currentUser)
    }

    func didTapSettings() {
        router?.navigateToSettings()
    }
    
    func didTapJoinGroup() {
        router?.openJoinGroup(for: currentUser)
    }

}
