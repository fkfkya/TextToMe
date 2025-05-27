import UIKit

final class CreateChatPresenter: CreateChatPresenterProtocol {

    weak var view: CreateChatViewProtocol?
    var interactor: CreateChatInteractorProtocol?
    var router: CreateChatRouterProtocol?

    private let currentUser: String

    init(currentUser: String) {
        self.currentUser = currentUser
    }

    func viewDidLoad() {}

    func didTapCreateDialog(with username: String) {
        interactor?.checkUserExists(username: username) { [weak self] exists in
            DispatchQueue.main.async {
                if exists {
                    self?.interactor?.createDialog(with: username) { chatId in
                        if let chatId {
                            self?.view?.showSuccessAndReturn(chatId: chatId)
                        } else {
                            self?.view?.showError("Не удалось создать диалог.")
                        }
                    }
                } else {
                    self?.view?.showError("Пользователь не найден.")
                }
            }
        }
    }


    func didTapCreateGroup(title: String?, users: [String], image: UIImage?) {
        interactor?.createGroup(title: title, users: users, image: image) { [weak self] chatId, joinCode in
            DispatchQueue.main.async {
                if let chatId, let joinCode {
                    self?.view?.showGeneratedJoinCode(joinCode)
                    self?.router?.navigateToChat(chatId: chatId)
                } else {
                    self?.view?.showError("Не удалось создать группу.")
                }
            }
        }
    }
    func notifyChatCreated() {
        router?.returnToChatListAndRefresh()
    }

}

