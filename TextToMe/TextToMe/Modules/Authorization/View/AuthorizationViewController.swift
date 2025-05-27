import UIKit
import Firebase

protocol AuthorizationViewProtocol: AnyObject {
    func promptForUUID()
    func showGeneratedUUID(_ uuid: String)
    func showLoginError()
}

final class AuthorizationViewController: UIViewController {

    // MARK: - VIPER
    var presenter: AuthorizationPresenterProtocol?
    private var cachedUUID: String?

    // MARK: - UI
    private let visualImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "loginVisual")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let imageSize: CGFloat = 260
        imageView.setWidth(mode: .equal, imageSize)
        imageView.setHeight(mode: .equal, imageSize)

        return imageView
    }()

    private lazy var nicknameField = styledTextField(placeholder: "Введите никнейм")
    private lazy var uuidField: UITextField = {
        let tf = styledTextField(placeholder: "Введите UUID")
        tf.isHidden = true
        return tf
    }()

    private let uuidLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorConstants.primaryYellow
        label.font = FontConstants.labelFont
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private let uuidHintLabel: UILabel = {
        let label = UILabel()
        label.text = "Сохраните данный код для будущей авторизации."
        label.font = FontConstants.smallItalic
        label.textColor = ColorConstants.hintGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private let usernameUsedLabel: UILabel = {
        let label = UILabel()
        label.text = "Данный никнейм уже занят.\nВведите код!"
        label.textColor = ColorConstants.errorRed
        label.font = FontConstants.labelFont
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private lazy var copyButton = styledButton(title: "Скопировать UUID", action: #selector(copyUUID))
    private lazy var goToChatsButton = styledButton(title: "Перейти к чатам", action: #selector(proceedToChats))
    private lazy var loginButton = styledButton(title: "Продолжить", action: #selector(handleLogin))

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConstants.background

        // Картинка и поле никнейма — вне основного стека
        view.addSubview(visualImageView)
        view.addSubview(nicknameField)

        visualImageView.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 32)
        visualImageView.pinCenterX(to: view.centerXAnchor)
        visualImageView.setWidth(mode: .equal, 200)
        visualImageView.setHeight(mode: .equal, 200)

        nicknameField.pinTop(to: visualImageView.bottomAnchor, 24)
        nicknameField.pinHorizontal(to: view, 32)
        nicknameField.setHeight(mode: .equal, 44)

        setupLayout()
        hideKeyboardWhenTappedAround()
    }

    // MARK: - Layout
    private func setupLayout() {
        let views = [
            usernameUsedLabel,
            uuidField,
            uuidLabel,
            uuidHintLabel,
            copyButton,
            goToChatsButton,
            loginButton
        ]

        views.forEach {
            view.addSubview($0)
            $0.pinLeft(to: view, LayoutConstants.horizontalPadding)
            $0.pinRight(to: view, LayoutConstants.horizontalPadding)
        }

        usernameUsedLabel.pinTop(to: nicknameField.bottomAnchor, LayoutConstants.verticalSpacing)
        uuidField.pinTop(to: usernameUsedLabel.bottomAnchor, LayoutConstants.verticalSpacing)
        uuidField.setHeight(LayoutConstants.fieldHeight)

        uuidLabel.pinTop(to: uuidField.bottomAnchor, LayoutConstants.verticalSpacing)
        uuidHintLabel.pinTop(to: uuidLabel.bottomAnchor, 8)
        copyButton.pinTop(to: uuidHintLabel.bottomAnchor, LayoutConstants.verticalSpacing)
        goToChatsButton.pinTop(to: copyButton.bottomAnchor, LayoutConstants.verticalSpacing)
        loginButton.pinTop(to: goToChatsButton.bottomAnchor, LayoutConstants.verticalSpacing)

        [copyButton, goToChatsButton, loginButton].forEach {
            $0.setHeight(LayoutConstants.buttonHeight)
        }

        // Изначально скрываем всё кроме никнейма
        uuidField.isHidden = true
        uuidLabel.isHidden = true
        uuidHintLabel.isHidden = true
        copyButton.isHidden = true
        goToChatsButton.isHidden = true
        loginButton.isHidden = false
        usernameUsedLabel.isHidden = true
    }

    // MARK: - UI Factory
    private func styledTextField(placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.font = FontConstants.fieldFont
        tf.textColor = ColorConstants.darkText
        tf.borderStyle = .none
        tf.layer.cornerRadius = LayoutConstants.cornerRadius
        tf.layer.borderWidth = 1
        tf.layer.borderColor = ColorConstants.fieldBorder.cgColor
        tf.backgroundColor = .clear

        let padding = UIView(frame: CGRect(x: 0, y: 0, width: LayoutConstants.fieldLeftPadding, height: 0))
        tf.leftView = padding
        tf.leftViewMode = .always

        return tf
    }

    private func styledButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(ColorConstants.buttonText, for: .normal)
        button.backgroundColor = ColorConstants.buttonBackground
        button.titleLabel?.font = FontConstants.buttonFont
        button.layer.cornerRadius = LayoutConstants.cornerRadius
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    // MARK: - Actions

    @objc private func handleLogin() {
        let nickname = nicknameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let uuid = uuidField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !nickname.isEmpty else {
            showAlert(message: "Поле \"Никнейм\" не может быть пустым.")
            return
        }

        if uuidField.isHidden {
            presenter?.handleNicknameInput(nickname)
        } else {
            guard !uuid.isEmpty else {
                showAlert(message: "Введите сохранённый UUID.")
                return
            }
            presenter?.handleUUIDInput(uuid)
        }
    }

    @objc private func copyUUID() {
        let uuid = cachedUUID ?? uuidLabel.text?.replacingOccurrences(of: "Your UUID:\n", with: "") ?? ""
        UIPasteboard.general.string = uuid
    }

    @objc private func proceedToChats() {
        if let uuid = cachedUUID {
            presenter?.handleUUIDInput(uuid)
        } else {
            showAlert(message: "UUID не найден. Повторите вход.")
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - AuthorizationViewProtocol
extension AuthorizationViewController: AuthorizationViewProtocol {
    func promptForUUID() {
        DispatchQueue.main.async {
            self.uuidField.isHidden = false
            self.usernameUsedLabel.isHidden = false
            self.uuidField.layer.borderColor = ColorConstants.fieldBorder.cgColor
        }
    }

    func showGeneratedUUID(_ uuid: String) {
        DispatchQueue.main.async {
            self.cachedUUID = uuid
            self.uuidLabel.text = "Your UUID:\n\(uuid)"
            self.uuidLabel.isHidden = false
            self.uuidHintLabel.isHidden = false
            self.copyButton.isHidden = false
            self.goToChatsButton.isHidden = false
            self.loginButton.isHidden = true
        }
    }

    func showLoginError() {
        let alert = UIAlertController(
            title: "Ошибка авторизации",
            message: "UUID не совпадает с никнеймом или не существует.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.uuidField.layer.borderColor = ColorConstants.errorRed.cgColor
            self.uuidField.text = ""
            self.uuidField.becomeFirstResponder()
        }))
        present(alert, animated: true)
    }
}
