import UIKit

enum CreateChatModuleBuilder {
    static func build(currentUser: String) -> UIViewController {
        let view = CreateChatViewController()
        let presenter = CreateChatPresenter(currentUser: currentUser)
        let interactor = CreateChatInteractor(currentUser: currentUser)
        let router = CreateChatRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        router.viewController = view

        return view
    }
}

