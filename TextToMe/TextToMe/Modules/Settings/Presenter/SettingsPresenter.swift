import Foundation
import UIKit

final class SettingsPresenter {
    weak var view: SettingsViewProtocol?
    let interactor: SettingsInteractorProtocol
    let router: SettingsRouterProtocol

    init(view: SettingsViewProtocol, interactor: SettingsInteractorProtocol, router: SettingsRouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

extension SettingsPresenter: SettingsPresenterProtocol {
    func viewDidLoad() {
        interactor.fetchCurrentUser()
    }

    func didTapLogout() {
        interactor.logoutUser()
    }

    func didTapChangeAvatar() {}
    func didTapChangeUsername(uuidConfirmation: String, newUsername: String) {}
    func didTapDeleteAccount() {
        interactor.deleteAccount()
    }
    func didTapResetUUID() {
        interactor.resetUUID()
    }
    func didToggleNotifications(enabled: Bool) {
        interactor.setNotificationsEnabled(enabled)
    }
    func didToggleBiometric(enabled: Bool) {
        interactor.setBiometricEnabled(enabled)
    }
}

extension SettingsPresenter: SettingsInteractorOutputProtocol {
    func didFetchUsername(_ username: String) {
        view?.showUsername(username)
    }

    func didFailToFetchUser(with error: Error) {
        view?.showError(error.localizedDescription)
    }

    func didLogout() {
        router.navigateToAuthorizationScreen()
    }

    func didChangeUsername(success: Bool) {}
    func didDeleteAccount(success: Bool) {}
    func didResetUUID(success: Bool) {}
    func didSetNotificationsEnabled(_ enabled: Bool) {}
    func didSetBiometricEnabled(_ enabled: Bool) {}
}

