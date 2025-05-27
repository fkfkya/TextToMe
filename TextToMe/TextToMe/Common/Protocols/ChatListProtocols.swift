import Foundation

protocol ChatListViewProtocol: AnyObject {
    func displayChats(_ chats: [ChatPreview])
}

protocol ChatListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didSelectChat(_ chat: ChatPreview)
    func didDeleteChat(_ chat: ChatPreview)
    func didTapNewChat()
    func didTapSettings()
    func didTapJoinGroup()

}

protocol ChatListInteractorProtocol: AnyObject {
    func fetchChats(for user: String)
    func removeChat(_ chat: ChatPreview)
}

protocol ChatListRouterProtocol: AnyObject {
    func navigateToChat(with id: String, currentUser: String)
    func navigateToCreateChat(currentUser: String)
    func navigateToSettings()
    func openJoinGroup(for user: String)

}

protocol ChatListInteractorOutputProtocol: AnyObject {
    func didLoadChats(_ chats: [ChatPreview])
}

