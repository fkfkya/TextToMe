import Foundation
import FirebaseFirestore

final class SettingsInteractor: SettingsInteractorProtocol {
    weak var presenter: SettingsInteractorOutputProtocol?

    private let keychain = KeychainService.shared
    private let firebase = FirebaseService.shared

    func fetchCurrentUser() {
        guard let nickname = keychain.getNickname() else {
            presenter?.didFailToFetchUser(with: NSError(domain: "Keychain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось получить никнейм пользователя из Keychain"]))
            return
        }

        firebase.checkIfUserExists(nickname: nickname) { [weak self] exists in
            guard exists else {
                self?.presenter?.didFailToFetchUser(with: NSError(domain: "Firestore", code: -2, userInfo: [NSLocalizedDescriptionKey: "Пользователь не найден в Firestore"]))
                return
            }
            self?.presenter?.didFetchUsername(nickname)
        }
    }

    func logoutUser() {
        keychain.deleteUUID()
        keychain.deleteNickname()
        presenter?.didLogout()
    }

    func deleteAccount() {
        keychain.deleteUUID()
        keychain.deleteNickname()
        presenter?.didDeleteAccount(success: true)
    }

    func resetUUID() {
        keychain.deleteUUID()
        keychain.deleteNickname()
        let newUUID = UUID().uuidString
        let _ = keychain.saveUUID(newUUID)
        presenter?.didResetUUID(success: true)
    }

    func setNotificationsEnabled(_ enabled: Bool) {
        presenter?.didSetNotificationsEnabled(enabled)
    }

    func setBiometricEnabled(_ enabled: Bool) {
        presenter?.didSetBiometricEnabled(enabled)
    }

    func changeUsername(newUsername: String, uuidConfirmation: String) {
        presenter?.didChangeUsername(success: true)
    }
}

