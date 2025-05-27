import UIKit

final class JoinGroupViewController: UIViewController {

    var presenter: JoinGroupPresenterProtocol?

    // Buttons
    private let codeField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Введите код группы"
        tf.layer.borderColor = UIColor.systemYellow.cgColor
        tf.layer.borderWidth = 2
        tf.layer.cornerRadius = 12
        tf.setHeight(44)
        tf.setLeftPaddingPoints(12)
        tf.backgroundColor = .secondarySystemBackground
        return tf
    }()

  
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

    
    private let joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Присоединиться", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemYellow
        button.layer.cornerRadius = 12
        button.setHeight(44)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Присоединение"
        setupUI()
        setupBackButton()
        joinButton.addTarget(self, action: #selector(joinTapped), for: .touchUpInside)
    }

    private func setupUI() {
        [codeField, joinButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            codeField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            codeField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            codeField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            joinButton.topAnchor.constraint(equalTo: codeField.bottomAnchor, constant: 20),
            joinButton.leadingAnchor.constraint(equalTo: codeField.leadingAnchor),
            joinButton.trailingAnchor.constraint(equalTo: codeField.trailingAnchor)
        ])
    }
    // Actions
    @objc private func joinTapped() {
        presenter?.didTapJoin(with: codeField.text ?? "")
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

}

extension JoinGroupViewController: JoinGroupViewProtocol {
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "ОК", style: .default))
        present(alert, animated: true)
    }

    func closeModule() {
        navigationController?.popViewController(animated: true)
    }
}
