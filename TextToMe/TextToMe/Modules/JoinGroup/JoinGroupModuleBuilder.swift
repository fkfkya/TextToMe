import UIKit

enum JoinGroupModuleBuilder {
    static func build(currentUser: String) -> UIViewController {
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
}
