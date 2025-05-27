import LocalAuthentication
import UIKit

final class BiometryService {
    static let shared = BiometryService()
    private init() {}

    private var biometricEnabled: Bool {
        UserDefaults.standard.bool(forKey: "biometricEnabled")
    }

    func requireUnlockIfNeeded(completion: (() -> Void)? = nil) {
        guard biometricEnabled else {
            completion?()
            return
        }

        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Разблокируйте приложение с помощью Face ID / Touch ID"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                DispatchQueue.main.async {
                    if success {
                        completion?()
                    } else {
                        self.blockAppPermanently()
                    }
                }
            }
        } else {
            completion?()
        }
    }

    private func blockAppPermanently() {
        exit(0)
    }
}
