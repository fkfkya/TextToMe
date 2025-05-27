import Foundation
import FirebaseFirestore

final class JoinGroupInteractor: JoinGroupInteractorProtocol {

    weak var output: JoinGroupInteractorOutput?
    private let db = Firestore.firestore()
    private let currentUser: String

    init(currentUser: String) {
        self.currentUser = currentUser
    }

    func joinGroup(with code: String) {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            output?.didFailToJoin("Введите код чата")
            return
        }

        db.collection("chats").document(trimmed).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }

            if let doc = snapshot, doc.exists {
                self.db.collection("users")
                    .document(self.currentUser)
                    .collection("chats")
                    .document(trimmed)
                    .setData(["joinedAt": Timestamp()]) { error in
                        if let error = error {
                            self.output?.didFailToJoin("Ошибка: \(error.localizedDescription)")
                        } else {
                            self.output?.didJoinSuccessfully()
                        }
                    }
            } else {
                self.output?.didFailToJoin("Чат с таким кодом не найден")
            }
        }
    }
}
