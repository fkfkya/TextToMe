import UIKit

final class CreateChatRouter: CreateChatRouterProtocol {

    weak var viewController: UIViewController?

    func navigateToChat(chatId: String) {
        let chatVC = ChatModuleBuilder.build(chatId: chatId, currentUser: KeychainService.shared.getNickname() ?? "")
        viewController?.navigationController?.pushViewController(chatVC, animated: true)
    }
    func returnToChatListAndRefresh() {
        guard let nav = viewController?.navigationController,
              let chatListVC = nav.viewControllers.first(where: { $0 is ChatListViewController }) as? ChatListViewController else {
            return
        }
        chatListVC.presenter?.viewDidLoad() 
    }

}

