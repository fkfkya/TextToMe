import UIKit

final class ChatRouter: ChatRouterProtocol {

    weak var viewController: UIViewController?

    static func assembleModule(chatId: String, currentUser: String) -> UIViewController {
        let view = ChatViewController()
        view.currentUser = currentUser

        let presenter = ChatPresenter(chatId: chatId, currentUser: currentUser)
        let interactor = ChatInteractor(chatId: chatId, currentUser: currentUser)
        let router = ChatRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.output = presenter
        router.viewController = view

        return view
    }

    func closeChat() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
