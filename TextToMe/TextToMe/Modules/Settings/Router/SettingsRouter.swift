import UIKit

final class SettingsRouter: SettingsRouterProtocol {
    weak var viewController: UIViewController?

    func navigateToAuthorizationScreen() {
        let authVC = AuthorizationModuleBuilder.build()
        let nav = UINavigationController(rootViewController: authVC)
        UIApplication.shared.windows.first?.rootViewController = nav
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
}
