import UIKit

final class ChatListViewController: UIViewController {

    var presenter: ChatListPresenterProtocol?
    var currentUser: String = ""

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Chats"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .left
        return label
    }()

    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Поиск по чатам"
        sb.searchBarStyle = .minimal
        sb.autocapitalizationType = .none
        return sb
    }()

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(ChatCell.self, forCellReuseIdentifier: ChatCell.reuseId)
        tv.separatorStyle = .singleLine
        tv.keyboardDismissMode = .onDrag
        return tv
    }()

    private var chats: [ChatPreview] = []
    private var filteredChats: [ChatPreview] = []
    private var isFiltering: Bool = false
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("🟡 ChatListViewController loaded for user: \(currentUser)")
        view.backgroundColor = .systemBackground
        hideKeyboardWhenTappedAround()
        setupUI()
        setupTable()
        presenter?.viewDidLoad()
    }

    private func setupUI() {
        [titleLabel, searchBar, tableView, newChatButton, joinGroupButton, settingsButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }


        NSLayoutConstraint.activate([
            settingsButton.widthAnchor.constraint(equalToConstant: 40),
            settingsButton.heightAnchor.constraint(equalToConstant: 40),
            settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            newChatButton.widthAnchor.constraint(equalToConstant: 56),
            newChatButton.heightAnchor.constraint(equalToConstant: 56),
            newChatButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            newChatButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),

            joinGroupButton.widthAnchor.constraint(equalToConstant: 56),
            joinGroupButton.heightAnchor.constraint(equalToConstant: 56),
            joinGroupButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            joinGroupButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])


        titleLabel.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 12)
        titleLabel.pinLeft(to: view, 16)

        searchBar.pinTop(to: titleLabel.bottomAnchor, 12)
        searchBar.pinLeft(to: view, 8)
        searchBar.pinRight(to: view, 8)

        tableView.pinTop(to: searchBar.bottomAnchor, 8)
        tableView.pinLeft(to: view)
        tableView.pinRight(to: view)
        tableView.pinBottom(to: view)

        newChatButton.addTarget(self, action: #selector(newChatTapped), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        joinGroupButton.addTarget(self, action: #selector(joinGroupTapped), for: .touchUpInside)

    }

    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshChats), for: .valueChanged)
    }

    @objc private func refreshChats() {
        presenter?.viewDidLoad()
    }

    @objc private func settingsTapped() {
        presenter?.didTapSettings()
    }

    @objc private func newChatTapped() {
        presenter?.didTapNewChat()
    }

    @objc private func joinGroupTapped() {
        presenter?.didTapJoinGroup()
    }

    // MARK: - Buttons
    private let joinGroupButton: UIButton = {
        let button = UIButton(type: .custom)
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
        let image = UIImage(systemName: "plus.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemYellow
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 4
        return button
    }()


    private let settingsButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(systemName: "gearshape.fill")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.backgroundColor = .systemYellow
        button.layer.cornerRadius = 20
        return button
    }()

    private let newChatButton: UIButton = {
        let button = UIButton(type: .custom)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        let image = UIImage(systemName: "bubble.left.and.bubble.right.fill", withConfiguration: config)

        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemYellow
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 4
        return button
    }()
}

// MARK: - ChatListViewProtocol

extension ChatListViewController: ChatListViewProtocol {
    func displayChats(_ chats: [ChatPreview]) {
        self.chats = chats
        self.filteredChats = chats
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
}

// MARK: - UITableView

extension ChatListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = isFiltering ? filteredChats.count : chats.count
        print("📊 tableView.count: \(count)")
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell.reuseId, for: indexPath) as? ChatCell else {
            return UITableViewCell()
        }

        let chat = isFiltering ? filteredChats[indexPath.row] : chats[indexPath.row]
        cell.configure(with: chat, currentUser: currentUser)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = isFiltering ? filteredChats[indexPath.row] : chats[indexPath.row]
        presenter?.didSelectChat(chat)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
            guard let self = self else { return }
            let chat = self.isFiltering ? self.filteredChats.remove(at: indexPath.row) : self.chats.remove(at: indexPath.row)
            self.presenter?.didDeleteChat(chat)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - UISearchBar

extension ChatListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        isFiltering = !searchText.isEmpty
        filteredChats = chats.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        tableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isFiltering = false
        searchBar.text = ""
        tableView.reloadData()
    }
}
