import Foundation

final class ChatPresenter: ChatPresenterProtocol {

    weak var view: ChatViewProtocol?
    var interactor: ChatInteractorProtocol?
    var router: ChatRouterProtocol?

    private let chatId: String
    private let currentUser: String

    init(chatId: String, currentUser: String) {
        self.chatId = chatId
        self.currentUser = currentUser
    }

    func viewDidLoad() {
        interactor?.loadInitialMessages()
        interactor?.observeMessages()
    }

    func sendMessage(_ text: String) {
        interactor?.sendMessage(text)
    }
    
    func closeChat() {
        router?.closeChat()
    }
    
    func sendMedia(data: Data, type: MediaType) {
        interactor?.sendMedia(data: data, type: type)
    }


}

// MARK: - ChatInteractorOutput
extension ChatPresenter: ChatInteractorOutput {
    func didLoadMessages(_ messages: [Message]) {
        view?.displayMessages(messages)
    }

    func didReceiveNewMessage(_ message: Message) {
        view?.appendMessage(message)
    }

    func didFail(with error: String) {
        view?.showError(error)
    }
}
