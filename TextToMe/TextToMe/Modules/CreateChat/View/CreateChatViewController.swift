import UIKit

final class CreateChatViewController: UIViewController {

    var presenter: CreateChatPresenterProtocol?

    // MARK: - UI Elements

    private let modeSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Диалог", "Группа"])
        sc.selectedSegmentIndex = 0
        sc.backgroundColor = .systemYellow
        sc.selectedSegmentTintColor = .black
        sc.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        sc.layer.cornerRadius = 8
        sc.layer.masksToBounds = true
        return sc
    }()

    private let usernameField = UITextField.makeRounded(placeholder: "Никнейм собеседника")
    private let groupTitleField = UITextField.makeRounded(placeholder: "Название группы (опционально)", hidden: true)

    private let memberField = UITextField.makeRounded(placeholder: "Введите ник участника", hidden: true)

    private let addMemberButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить участника", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.47, green: 0.88, blue: 0.67, alpha: 1.0)
        button.layer.cornerRadius = 8
        button.isHidden = true
        return button
    }()

    private let addedUsersView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.isHidden = true
        return stack
    }()

    private let avatarPreview: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 40
        iv.clipsToBounds = true
        iv.layer.borderColor = UIColor.systemYellow.cgColor
        iv.layer.borderWidth = 2
        iv.isHidden = true
        return iv
    }()

    private let avatarButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Установить фотографию чата", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 0.47, green: 0.88, blue: 0.67, alpha: 1.0)
        btn.layer.cornerRadius = 12
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        btn.isHidden = true
        return btn
    }()

    private let createButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Создать чат", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.backgroundColor = .systemYellow
        btn.setTitleColor(.black, for: .normal)
        btn.layer.cornerRadius = 10
        return btn
    }()

    private var selectedAvatar: UIImage?
    private var addedUsers: [String] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        hideKeyboardWhenTappedAround()
        setupBackButton()
        setupUI()
        modeSegmentedControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        avatarButton.addTarget(self, action: #selector(pickAvatar), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createChatTapped), for: .touchUpInside)
        addMemberButton.addTarget(self, action: #selector(addMemberTapped), for: .touchUpInside)
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

    // MARK: - UI Setup

    private func setupUI() {
        [modeSegmentedControl, usernameField, groupTitleField, memberField, addMemberButton, addedUsersView, avatarPreview, avatarButton, createButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        modeSegmentedControl.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 20)
        modeSegmentedControl.pinLeft(to: view, 20)
        modeSegmentedControl.pinRight(to: view, 20)

        usernameField.pinTop(to: modeSegmentedControl.bottomAnchor, 24)
        usernameField.pinLeft(to: view, 20)
        usernameField.pinRight(to: view, 20)

        groupTitleField.pinTop(to: modeSegmentedControl.bottomAnchor, 24)
        groupTitleField.pinLeft(to: view, 20)
        groupTitleField.pinRight(to: view, 20)

        memberField.pinTop(to: groupTitleField.bottomAnchor, 16)
        memberField.pinLeft(to: view, 20)
        memberField.pinRight(to: view, 20)

        addMemberButton.pinTop(to: memberField.bottomAnchor, 8)
        addMemberButton.pinLeft(to: view, 20)
        addMemberButton.pinRight(to: view, 20)
        addMemberButton.setHeight(44)

        addedUsersView.pinTop(to: addMemberButton.bottomAnchor, 8)
        addedUsersView.pinLeft(to: view, 20)
        addedUsersView.pinRight(to: view, 20)

        avatarPreview.pinTop(to: addedUsersView.bottomAnchor, 12)
        avatarPreview.pinCenterX(to: view.centerXAnchor)
        avatarPreview.setWidth(80)
        avatarPreview.setHeight(80)

        avatarButton.pinTop(to: avatarPreview.bottomAnchor, 8)
        avatarButton.pinCenterX(to: view.centerXAnchor)

        createButton.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, 24)
        createButton.pinLeft(to: view, 40)
        createButton.pinRight(to: view, 40)
        createButton.setHeight(48)
    }

    // MARK: - Actions

    func showSuccessAndReturn(chatId: String) {
        let alert = UIAlertController(title: "Чат создан", message: "Вы успешно начали диалог.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Перейти в чат", style: .default) { [weak self] _ in
            self?.presenter?.notifyChatCreated()
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }

    func didCreateDialog(chatId: String) {
        presenter?.notifyChatCreated()
    }

    @objc private func modeChanged() {
        let isGroup = modeSegmentedControl.selectedSegmentIndex == 1
        usernameField.isHidden = isGroup
        groupTitleField.isHidden = !isGroup
        memberField.isHidden = !isGroup
        addMemberButton.isHidden = !isGroup
        addedUsersView.isHidden = !isGroup
        avatarButton.isHidden = !isGroup
        avatarPreview.isHidden = !isGroup
    }

    @objc private func pickAvatar() {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func addMemberTapped() {
        guard let text = memberField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return }
        guard !addedUsers.contains(text) else { return }

        addedUsers.append(text)

        let label = UILabel()
        label.text = text
        label.textColor = .label
        label.font = .systemFont(ofSize: 16)

        let deleteButton = UIButton(type: .system)
        deleteButton.setImage(UIImage(systemName: "trash.fill"), for: .normal)
        deleteButton.tintColor = .systemRed
        deleteButton.addTarget(self, action: #selector(removeUserButtonTapped(_:)), for: .touchUpInside)

        let horizontalStack = UIStackView(arrangedSubviews: [label, deleteButton])
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 12
        horizontalStack.alignment = .center
        horizontalStack.tag = addedUsers.count - 1 

        addedUsersView.addArrangedSubview(horizontalStack)
        memberField.text = ""
    }


    @objc private func removeUserLabel(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel, let text = label.text?.replacingOccurrences(of: "  🗙", with: "") else { return }
        addedUsers.removeAll { $0 == text }
        addedUsersView.removeArrangedSubview(label)
        label.removeFromSuperview()
    }
    @objc private func removeUserButtonTapped(_ sender: UIButton) {
        guard let stack = sender.superview as? UIStackView else { return }
        if let index = addedUsersView.arrangedSubviews.firstIndex(of: stack) {
            addedUsers.remove(at: index)
            addedUsersView.removeArrangedSubview(stack)
            stack.removeFromSuperview()
        }
    }

    @objc private func createChatTapped() {
        if modeSegmentedControl.selectedSegmentIndex == 0 {
            guard let nickname = usernameField.text, !nickname.isEmpty else {
                showError("Введите никнейм собеседника")
                return
            }
            presenter?.didTapCreateDialog(with: nickname)
        } else {
            let groupTitle = groupTitleField.text
            presenter?.didTapCreateGroup(title: groupTitle, users: addedUsers, image: selectedAvatar)
        }
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Image Picker

extension CreateChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectedAvatar = image
            avatarPreview.image = image
            avatarPreview.isHidden = false
            avatarButton.setTitle("Изменить фотографию", for: .normal)
        }
        picker.dismiss(animated: true)
    }
}

// MARK: - View Protocol

extension CreateChatViewController: CreateChatViewProtocol {
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }

    func showGeneratedJoinCode(_ code: String) {
        let alert = UIAlertController(title: "Код приглашения", message: "Код для вступления в чат:\n\(code)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Скопировать", style: .default, handler: { [weak self] _ in
            UIPasteboard.general.string = code
            self?.navigationController?.popViewController(animated: true)
            self?.presenter?.notifyChatCreated()
        }))
        alert.addAction(UIAlertAction(title: "Закрыть", style: .cancel, handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
            self?.presenter?.notifyChatCreated()
        }))
        present(alert, animated: true)
    }
}

// MARK: - UITextField Utility

private extension UITextField {
    static func makeRounded(placeholder: String, hidden: Bool = false) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.borderStyle = .roundedRect
        tf.isHidden = hidden
        return tf
    }
}
