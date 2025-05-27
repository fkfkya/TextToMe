import UIKit
import AVFoundation

final class ChatViewController: UIViewController {

    // MARK: - VIPER
    var presenter: ChatPresenterProtocol?
    var currentUser: String = ""
    var chatTitle: String = ""

    private var messages: [Message] = []

    // MARK: - UI
    private let tableView = UITableView()
    private let inputContainer = UIView()
    private let inputField = UITextField()
    private let sendButton = UIButton(type: .custom)
    private let mediaButton = UIButton(type: .system)
    private var audioRecorder: AVAudioRecorder?
    private var audioSession: AVAudioSession!

    private var bottomConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        navigationItem.title = chatTitle
        setupBackButton()
        setupUI()
        setupKeyboardObservers()
        presenter?.viewDidLoad()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI

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
    
    private func setupUI() {
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reuseId)
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension

        // inputField
        inputField.placeholder = "Сообщение"
        inputField.borderStyle = .none
        inputField.backgroundColor = .black
        inputField.layer.borderColor = UIColor.systemYellow.cgColor
        inputField.layer.cornerRadius = 20
        inputField.layer.masksToBounds = true
        inputField.setHeight(40)

        sendButton.setImage(UIImage(named: "catPaw")?.withRenderingMode(.alwaysTemplate), for: .normal)
        sendButton.tintColor = .systemYellow
        sendButton.setWidth(40)
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)

        mediaButton.setImage(UIImage(systemName: "photo"), for: .normal)
        mediaButton.tintColor = .gray
        mediaButton.setWidth(40)
        mediaButton.addTarget(self, action: #selector(mediaTapped), for: .touchUpInside)

        // layout
        [tableView, inputContainer].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        [inputField, mediaButton, sendButton].forEach {
            inputContainer.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        tableView.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
        tableView.pinLeft(to: view)
        tableView.pinRight(to: view)
        tableView.pinBottom(to: inputContainer.topAnchor)

        inputField.pinLeft(to: inputContainer, 16)
        inputField.pinTop(to: inputContainer, 8)
        inputField.pinBottom(to: inputContainer, 8)
        inputField.pinRight(to: mediaButton.leadingAnchor, 8)

        mediaButton.pinTop(to: inputContainer, 8)
        mediaButton.pinBottom(to: inputContainer, 8)
        mediaButton.pinRight(to: sendButton.leadingAnchor, 4)

        sendButton.pinTop(to: inputContainer, 8)
        sendButton.pinRight(to: inputContainer, 16)
        sendButton.pinBottom(to: inputContainer, 8)

        inputContainer.pinLeft(to: view)
        inputContainer.pinRight(to: view)
        bottomConstraint = inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        bottomConstraint?.isActive = true
    }


    // MARK: - Keyboard Handling

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)

        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    @objc private func keyboardWillShow(_ note: Notification) {
        guard let info = note.userInfo,
              let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }

        bottomConstraint?.constant = -keyboardFrame.height + view.safeAreaInsets.bottom
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ note: Notification) {
        guard let duration = (note.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) else { return }
        bottomConstraint?.constant = 0
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Actions

    @objc private func backTapped() {
        presenter?.closeChat()
    }

    @objc private func sendTapped() {
        guard let text = inputField.text, !text.isEmpty else { return }
        presenter?.sendMessage(text)
        inputField.text = ""
    }

    @objc private func mediaTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.mediaTypes = ["public.image", "public.movie"]
        present(picker, animated: true)
    }

    private func scrollToBottom() {
        guard !messages.isEmpty else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

// MARK: - ChatViewProtocol

extension ChatViewController: ChatViewProtocol {
    func displayMessages(_ messages: [Message]) {
        self.messages = messages
        tableView.reloadData()
        scrollToBottom()
    }

    func appendMessage(_ message: Message) {
        messages.append(message)
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .bottom)
        scrollToBottom()
    }

    func showError(_ error: String) {
        let alert = UIAlertController(title: "Ошибка", message: error, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.reuseId, for: indexPath) as? MessageCell else {
            return UITableViewCell()
        }
        cell.configure(with: message, currentUser: self.currentUser)

        return cell
    }
}

// MARK: - Media Picker

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        if let image = info[.originalImage] as? UIImage,
           let data = image.jpegData(compressionQuality: 0.8) {
            presenter?.sendMedia(data: data, type: .image)
        } else if let videoURL = info[.mediaURL],
                  let videoData = try? Data(contentsOf: videoURL as! URL) {
            presenter?.sendMedia(data: videoData, type: .video)
        }
    }
}

