import UIKit

final class JoinGroupRouter: JoinGroupRouterProtocol {
    weak var viewController: UIViewController?

    static func assembleModule(currentUser: String) -> UIViewController {
        let view = JoinGroupViewController()
        let presenter = JoinGroupPresenter(currentUser: currentUser)
        let interactor = JoinGroupInteractor(currentUser: currentUser)
        let router = JoinGroupRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.output = presenter
        router.viewController = view

        return view
    }

    func dismiss() {
        viewController?.navigationController?.popViewController(animated: true)
    }
    
    func returnToChatListAndRefresh() {
        guard let nav = viewController?.navigationController,
              let chatListVC = nav.viewControllers.first(where: { $0 is ChatListViewController }) as? ChatListViewController else {
            return
        }
        chatListVC.presenter?.viewDidLoad()
    }

}
