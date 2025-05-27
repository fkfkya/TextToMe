import UIKit
import PhotosUI
import UserNotifications

final class SettingsViewController: UIViewController {
    var presenter: SettingsPresenterProtocol?

    private let usernameLabel = UILabel()
    private let logoutButton = UIButton(type: .system)
    private let changeAvatarButton = UIButton(type: .system)
    private let changeUsernameButton = UIButton(type: .system)
    private let deleteAccountButton = UIButton(type: .system)
    private let resetUUIDButton = UIButton(type: .system)
    private let notificationsSwitch = UISwitch()
    private let biometricSwitch = UISwitch()
    private let avatarImageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        setupUI()
        loadSwitchStates()
        loadAvatarFromDefaults()
        presenter?.viewDidLoad()
        
    }

    private func setupUI() {
        view.backgroundColor = .black
        title = "Настройки"

        // Avatar
        avatarImageView.image = UIImage(systemName: "person.crop.circle")
        avatarImageView.tintColor = .systemYellow
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true

        let avatarSize: CGFloat = 120
        avatarImageView.setWidth(mode: .equal, avatarSize)
        avatarImageView.setHeight(mode: .equal, avatarSize)
        avatarImageView.layer.cornerRadius = avatarSize / 2


        // Username
        usernameLabel.font = .boldSystemFont(ofSize: 24)
        usernameLabel.textAlignment = .center
        usernameLabel.textColor = .systemYellow

        // Buttons setup
        let buttons = [changeAvatarButton, changeUsernameButton, resetUUIDButton, deleteAccountButton]
        buttons.forEach {
            $0.setTitleColor(.black, for: .normal)
            $0.backgroundColor = .systemYellow
            $0.layer.cornerRadius = 8
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.setHeight(mode: .equal, 44)
            $0.setWidth(mode: .equal, 250)
        }

        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.backgroundColor = .systemRed
        logoutButton.layer.cornerRadius = 8
        logoutButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        logoutButton.setHeight(mode: .equal, 44)
        logoutButton.setWidth(mode: .equal, 250)

        // Titles
        changeAvatarButton.setTitle("Сменить аватар", for: .normal)
        changeUsernameButton.setTitle("Сменить имя пользователя", for: .normal)
        resetUUIDButton.setTitle("Сбросить UUID", for: .normal)
        deleteAccountButton.setTitle("Удалить аккаунт", for: .normal)
        logoutButton.setTitle("Выйти", for: .normal)

        // Targets
        biometricSwitch.addTarget(self, action: #selector(biometricSwitchChanged), for: .valueChanged)
        notificationsSwitch.addTarget(self, action: #selector(notificationsSwitchChanged), for: .valueChanged)
        deleteAccountButton.addTarget(self, action: #selector(deleteAccountTapped), for: .touchUpInside)
        changeUsernameButton.addTarget(self, action: #selector(changeUsernameTapped), for: .touchUpInside)
        changeAvatarButton.addTarget(self, action: #selector(changeAvatarTapped), for: .touchUpInside)
        resetUUIDButton.addTarget(self, action: #selector(resetUUIDTapped), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)

        // Switch labels
        let notificationLabel = UILabel()
        notificationLabel.text = "Уведомления"
        notificationLabel.textColor = .systemYellow
        let biometricLabel = UILabel()
        biometricLabel.text = "Face ID / Touch ID"
        biometricLabel.textColor = .systemYellow

        let notificationStack = UIStackView(arrangedSubviews: [notificationLabel, notificationsSwitch])
        notificationStack.axis = .horizontal
        notificationStack.spacing = 16
        notificationStack.alignment = .center

        let biometricStack = UIStackView(arrangedSubviews: [biometricLabel, biometricSwitch])
        biometricStack.axis = .horizontal
        biometricStack.spacing = 16
        biometricStack.alignment = .center

        let stack = UIStackView(arrangedSubviews: [
            avatarImageView,
            usernameLabel,
            changeAvatarButton,
            changeUsernameButton,
            resetUUIDButton,
            deleteAccountButton,
            notificationStack,
            biometricStack,
            logoutButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center

        view.addSubview(stack)
        stack.pinCenter(to: view)
    }

    private func setupBackButton() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.backward"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        backButton.tintColor = .systemYellow
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func requestPushNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                } else {
                    self.showError("Пользователь запретил уведомления.")
                }
            }
        }
    }

    
    // MARK: - Actions
    @objc private func notificationsSwitchChanged() {
        saveSwitchStates()
        presenter?.didToggleNotifications(enabled: notificationsSwitch.isOn)

        if notificationsSwitch.isOn {
            requestPushNotificationPermission()
        } else {

        }
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func changeUsernameTapped() {
        let alert = UIAlertController(title: "Смена имени", message: "Введите ваш UUID и новый никнейм", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "UUID" }
        alert.addTextField { $0.placeholder = "Новый никнейм" }

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Сменить", style: .default) { [weak self] _ in
            guard let fields = alert.textFields,
                  let uuid = fields[0].text,
                  let newUsername = fields[1].text else { return }
            self?.presenter?.didTapChangeUsername(uuidConfirmation: uuid, newUsername: newUsername)
        })

        present(alert, animated: true)
    }

    @objc private func resetUUIDTapped() {
        let alert = UIAlertController(title: "Сброс UUID", message: "Это приведёт к потере всех переписок. Продолжить?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Сбросить", style: .destructive) { [weak self] _ in
            self?.presenter?.didTapResetUUID()
        })
        present(alert, animated: true)
    }

    @objc private func deleteAccountTapped() {
        let alert = UIAlertController(title: "Удалить аккаунт", message: "Все ваши данные будут удалены. Вы уверены?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.presenter?.didTapDeleteAccount()
        })
        present(alert, animated: true)
    }

    @objc private func logoutTapped() {
        let alert = UIAlertController(title: "Выход из аккаунта", message: "Вы действительно хотите выйти?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive) { [weak self] _ in
            self?.presenter?.didTapLogout()
        })
        present(alert, animated: true)
    }

    @objc private func changeAvatarTapped() {
        presentImagePicker()
    }

    @objc private func biometricSwitchChanged() {
        saveSwitchStates()
        presenter?.didToggleBiometric(enabled: biometricSwitch.isOn)
    }


    // MARK: - UserDefaults

    private func saveSwitchStates() {
        UserDefaults.standard.set(notificationsSwitch.isOn, forKey: "notificationsEnabled")
        UserDefaults.standard.set(biometricSwitch.isOn, forKey: "biometricEnabled")
    }

    private func loadSwitchStates() {
        notificationsSwitch.isOn = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        biometricSwitch.isOn = UserDefaults.standard.bool(forKey: "biometricEnabled")
    }

    private func saveAvatarToDefaults(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(data, forKey: "userAvatar")
        }
    }

    private func loadAvatarFromDefaults() {
        if let data = UserDefaults.standard.data(forKey: "userAvatar"),
           let image = UIImage(data: data) {
            avatarImageView.image = image
        }
    }

    // MARK: - Avatar Picker

    private func presentImagePicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension SettingsViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else { return }

        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            DispatchQueue.main.async {
                if let image = image as? UIImage {
                    self?.avatarImageView.image = image
                    self?.saveAvatarToDefaults(image)
                    self?.presenter?.didTapChangeAvatar()
                }
            }
        }
    }
}

// MARK: - SettingsViewProtocol

extension SettingsViewController: SettingsViewProtocol {
    func showUsername(_ username: String) {
        usernameLabel.text = username
    }

    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
}
