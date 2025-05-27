import UIKit

final class ChatListRouter: ChatListRouterProtocol {
    weak var viewController: UIViewController?

    func navigateToChat(with id: String, currentUser: String) {
        let chatVC = ChatModuleBuilder.build(chatId: id, currentUser: currentUser)
        viewController?.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func navigateToCreateChat(currentUser: String) {
        let createVC = CreateChatModuleBuilder.build(currentUser: currentUser)
        viewController?.navigationController?.pushViewController(createVC, animated: true)
    }
    func navigateToSettings() {
        let settingsModule = SettingsModuleBuilder.build()
        viewController?.navigationController?.pushViewController(settingsModule, animated: true)
    }
    func openJoinGroup(for user: String) {
        let joinGroupVC = JoinGroupModuleBuilder.build(currentUser: user)
        viewController?.navigationController?.pushViewController(joinGroupVC, animated: true)
    }



}
