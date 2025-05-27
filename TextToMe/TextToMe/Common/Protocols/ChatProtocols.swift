import Foundation

protocol ChatPresenterProtocol: AnyObject {
    func viewDidLoad()
    func sendMessage(_ text: String)
    func sendMedia(data: Data, type: MediaType)
    func closeChat()
}


protocol ChatViewProtocol: AnyObject {
    func displayMessages(_ messages: [Message])
    func appendMessage(_ message: Message)
    func showError(_ error: String)
}

protocol ChatInteractorProtocol: AnyObject {
    func loadInitialMessages()
    func observeMessages()
    func sendMessage(_ text: String)
    func sendMedia(data: Data, type: MediaType)
}

protocol ChatInteractorOutput: AnyObject {
    func didLoadMessages(_ messages: [Message])
    func didReceiveNewMessage(_ message: Message)
    func didFail(with error: String)
}

protocol ChatRouterProtocol: AnyObject {
    func closeChat()
}
