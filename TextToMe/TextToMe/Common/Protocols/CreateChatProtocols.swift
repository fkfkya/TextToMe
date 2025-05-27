import UIKit

protocol CreateChatViewProtocol: AnyObject {
    func showError(_ message: String)
    func showGeneratedJoinCode(_ code: String)
    func showSuccessAndReturn(chatId: String) 
}

protocol CreateChatPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapCreateDialog(with username: String)
    func didTapCreateGroup(title: String?, users: [String], image: UIImage?)
    func notifyChatCreated()

}

protocol CreateChatInteractorProtocol: AnyObject {
    func checkUserExists(username: String, completion: @escaping (Bool) -> Void)
    func createDialog(with username: String, completion: @escaping (String?) -> Void)
    func createGroup(title: String?, users: [String], image: UIImage?, completion: @escaping (String?, String?) -> Void)
}

protocol CreateChatRouterProtocol: AnyObject {
    func navigateToChat(chatId: String)
    func returnToChatListAndRefresh()
    
}
