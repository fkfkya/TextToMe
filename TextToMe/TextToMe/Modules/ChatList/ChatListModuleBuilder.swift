import UIKit

enum ChatListModuleBuilder {
    static func build(currentUser: String) -> UIViewController {
        let view = ChatListViewController()
        let presenter = ChatListPresenter(currentUser: currentUser)
        let interactor = ChatListInteractor(currentUser: currentUser)
        let router = ChatListRouter()

        view.presenter = presenter
        view.currentUser = currentUser
        interactor.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        router.viewController = view

        return view
    }

}
