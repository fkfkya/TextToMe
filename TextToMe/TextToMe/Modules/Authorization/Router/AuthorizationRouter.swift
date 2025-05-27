import UIKit

protocol AuthorizationRouterProtocol {
    func navigateToMain(currentUser: String)
}

final class AuthorizationRouter: AuthorizationRouterProtocol {
    weak var viewController: UIViewController?

    func navigateToMain(currentUser: String) {
        let chatListVC = ChatListModuleBuilder.build(currentUser: currentUser)
        viewController?.navigationController?.setViewControllers([chatListVC], animated: true)
    }

    static func assembleModule() -> UIViewController {
        let view = AuthorizationViewController()
        let presenter = AuthorizationPresenter()
        let interactor = AuthorizationInteractor()
        let router = AuthorizationRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        router.viewController = view

        return view
    }
}
