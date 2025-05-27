import Foundation

protocol AuthorizationPresenterProtocol {
    func handleNicknameInput(_ nickname: String)
    func handleUUIDInput(_ uuid: String)
}

final class AuthorizationPresenter: AuthorizationPresenterProtocol {
    weak var view: AuthorizationViewProtocol?
    var interactor: AuthorizationInteractorProtocol?
    var router: AuthorizationRouterProtocol?

    private var cachedNickname: String?

    func handleNicknameInput(_ nickname: String) {
        cachedNickname = nickname

        interactor?.checkIfUserExists(nickname: nickname) { [weak self] exists in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if exists {
                    self.view?.promptForUUID()
                } else {
                    self.interactor?.createUser(nickname: nickname) { uuid in
                        guard uuid != "ERROR" else {
                            self.view?.showLoginError()
                            return
                        }
                        KeychainService.shared.saveUUID(uuid)
                        KeychainService.shared.saveNickname(nickname)

                        self.view?.showGeneratedUUID(uuid)
                    }
                }
            }
        }
    }

    func handleUUIDInput(_ uuid: String) {
        if uuid.isEmpty, let cachedUUID = KeychainService.shared.getUUID() {
            handleUUIDInput(cachedUUID)
            return
        }

        guard let nickname = cachedNickname else {
            view?.showLoginError()
            return
        }

        interactor?.loginUser(nickname: nickname, uuid: uuid) { [weak self] success in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if success {
                    KeychainService.shared.saveNickname(nickname)
                    self.router?.navigateToMain(currentUser: nickname)
                } else {
                    self.view?.showLoginError()
                }
            }
        }
    }
}
