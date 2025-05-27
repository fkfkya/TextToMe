import UIKit

// MARK: - View -> Presenter
protocol SettingsPresenterProtocol: AnyObject {
    func didToggleBiometric(enabled: Bool)
    func didToggleNotifications(enabled: Bool)
    func didTapResetUUID()
    func didTapDeleteAccount()
    func didTapChangeUsername(uuidConfirmation: String, newUsername: String)
    func didTapChangeAvatar()
    func viewDidLoad()
    func didTapLogout()
}

// MARK: - Presenter -> View
protocol SettingsViewProtocol: AnyObject {
    func showUsername(_ username: String)
    func showError(_ message: String)
}

// MARK: - Presenter -> Interactor
protocol SettingsInteractorProtocol: AnyObject {
    func changeUsername(newUsername: String, uuidConfirmation: String)
    func deleteAccount()
    func resetUUID()
    func setNotificationsEnabled(_ enabled: Bool)
    func setBiometricEnabled(_ enabled: Bool)
    func fetchCurrentUser()
    func logoutUser()
}

// MARK: - Interactor -> Presenter
protocol SettingsInteractorOutputProtocol: AnyObject {
    func didChangeUsername(success: Bool)
    func didDeleteAccount(success: Bool)
    func didResetUUID(success: Bool)
    func didSetNotificationsEnabled(_ enabled: Bool)
    func didSetBiometricEnabled(_ enabled: Bool)
    func didFetchUsername(_ username: String)
    func didFailToFetchUser(with error: Error)
    func didLogout()
}

// MARK: - Presenter -> Router
protocol SettingsRouterProtocol: AnyObject {
    func navigateToAuthorizationScreen()
}

