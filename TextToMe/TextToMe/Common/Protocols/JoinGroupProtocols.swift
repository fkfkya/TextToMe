import Foundation

protocol JoinGroupViewProtocol: AnyObject {
    func showError(_ message: String)
    func closeModule()
}

protocol JoinGroupPresenterProtocol: AnyObject {
    func didTapJoin(with code: String)
}

protocol JoinGroupInteractorProtocol: AnyObject {
    func joinGroup(with code: String)
}

protocol JoinGroupInteractorOutput: AnyObject {
    func didJoinSuccessfully()
    func didFailToJoin(_ message: String)
}

protocol JoinGroupRouterProtocol: AnyObject {
    func dismiss()
    func returnToChatListAndRefresh()
}
