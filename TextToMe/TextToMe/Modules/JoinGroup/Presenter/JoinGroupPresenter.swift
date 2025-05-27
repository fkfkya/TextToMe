import Foundation

final class JoinGroupPresenter: JoinGroupPresenterProtocol {

    weak var view: JoinGroupViewProtocol?
    var interactor: JoinGroupInteractorProtocol?
    var router: JoinGroupRouterProtocol?

    private let currentUser: String

    init(currentUser: String) {
        self.currentUser = currentUser
    }

    func didTapJoin(with code: String) {
        interactor?.joinGroup(with: code)
    }
}

extension JoinGroupPresenter: JoinGroupInteractorOutput {
    func didJoinSuccessfully() {
        view?.closeModule()
    }

    func didFailToJoin(_ message: String) {
        view?.showError(message)
    }
}
