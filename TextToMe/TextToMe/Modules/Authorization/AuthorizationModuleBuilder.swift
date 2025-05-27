import UIKit

final class AuthorizationModuleBuilder {
    static func build() -> UIViewController {
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
