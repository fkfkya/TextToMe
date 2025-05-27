import Foundation
import FirebaseFirestore

final class ChatService {
    static let shared = ChatService()
    private init() {}

    private let db = Firestore.firestore()

    func loadChats(for username: String, completion: @escaping ([ChatPreview]) -> Void) {
        print("⚙️ Загружаем чаты для пользователя: \(username)")
        
        let userChatsRef = db.collection("users").document(username).collection("chats")
        userChatsRef.getDocuments { snapshot, error in
            if let error = error {
                print("❌ Ошибка получения подколлекции: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let documents = snapshot?.documents else {
                print("⚠️ Чатов не найдено.")
                completion([])
                return
            }

            print("📄 Найдено \(documents.count) ссылок на чаты")

            var result: [ChatPreview] = []
            let group = DispatchGroup()

            for doc in documents {
                let chatId = doc.documentID
                group.enter()

                self.db.collection("chats").document(chatId).getDocument { chatDoc, error in
                    defer { group.leave() }

                    if let error = error {
                        print("❌ Ошибка получения чата \(chatId): \(error.localizedDescription)")
                        return
                    }

                    guard let data = chatDoc?.data() else {
                        print("⚠️ Чат \(chatId) не существует")
                        return
                    }

                    let name = data["title"] as? String
                        ?? data["name"] as? String
                        ?? chatId

                    let lastMessage = data["lastMessage"] as? String ?? ""
                    let timestamp = data["lastMessageDate"] as? Timestamp
                    let lastMessageDate = timestamp?.dateValue()
                    let type = data["type"] as? String ?? "dialog"
                    let avatarURL = data["avatarURL"] as? String
                    let members = data["members"] as? [String] ?? []

                    let chat = ChatPreview(
                        id: chatId,
                        name: name,
                        lastMessage: lastMessage,
                        lastMessageDate: lastMessageDate,
                        type: type,
                        members: members,
                        avatarURL: avatarURL
                    )

                    result.append(chat)
                }
            }

            group.notify(queue: .main) {
                print("✅ Загружено \(result.count) чатов")
                let sorted = result.sorted {
                    ($0.lastMessageDate ?? Date.distantPast) > ($1.lastMessageDate ?? Date.distantPast)
                }
                completion(sorted)
            }
        }
    }

    func deleteChat(_ chatId: String, for username: String, completion: (() -> Void)? = nil) {
        db.collection("users").document(username)
            .collection("chats").document(chatId).delete { error in
                if let error = error {
                    print("❌ Ошибка удаления чата: \(error.localizedDescription)")
                } else {
                    print("✅ Чат \(chatId) удалён у пользователя \(username)")
                }
                completion?()
            }
    }
}
