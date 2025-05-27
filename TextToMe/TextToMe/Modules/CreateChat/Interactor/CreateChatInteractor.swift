import UIKit
import FirebaseFirestore
import FirebaseStorage

final class CreateChatInteractor: CreateChatInteractorProtocol {

    private let currentUser: String
    private let db = Firestore.firestore()

    init(currentUser: String) {
        self.currentUser = currentUser
    }
    
    private func linkChatToUsers(chatId: String, users: [String]) {
        print("🔗 Привязка чата \(chatId) к пользователям: \(users)")
        for user in users {
            db.collection("users")
                .document(user)
                .collection("chats")
                .document(chatId)
                .setData(["linkedAt": FieldValue.serverTimestamp()]) { error in
                    if let error = error {
                    } else {
                    }
                }
        }
    }



    func checkUserExists(username: String, completion: @escaping (Bool) -> Void) {
        db.collection("users").document(username).getDocument { snapshot, _ in
            completion(snapshot?.exists == true)
        }
    }

    func createDialog(with username: String, completion: @escaping (String?) -> Void) {
        let chatId = UUID().uuidString

        let members = [currentUser, username]
        let data: [String: Any] = [
            "type": "dialog",
            "members": members,
            "createdAt": FieldValue.serverTimestamp()
        ]

        db.collection("chats").document(chatId).setData(data) { [weak self] error in
            guard error == nil else {
                completion(nil)
                return
            }
            self?.linkChatToUsers(chatId: chatId, users: members)
            completion(chatId)
        }
    }


    func createGroup(title: String?, users: [String], image: UIImage?, completion: @escaping (String?, String?) -> Void) {
        let chatId = UUID().uuidString
        let joinCode = UUID().uuidString.prefix(6).uppercased()
        let allUsers = [currentUser] + users

        var chatData: [String: Any] = [
            "type": "group",
            "members": allUsers,
            "createdAt": FieldValue.serverTimestamp(),
            "admin": currentUser,
            "joinCode": joinCode
        ]

        if let title, !title.isEmpty {
            chatData["title"] = title
        }

        func uploadImageAndCreate(_ avatarURL: String?) {
            if let avatarURL = avatarURL {
                chatData["avatarURL"] = avatarURL
            }

            db.collection("chats").document(chatId).setData(chatData) { [weak self] error in
                if error == nil {
                    self?.linkChatToUsers(chatId: chatId, users: allUsers)
                }
                completion(error == nil ? chatId : nil, error == nil ? String(joinCode) : nil)
            }

        }

        if let image = image, let data = image.jpegData(compressionQuality: 0.8) {
            let ref = Storage.storage().reference().child("avatars/\(chatId).jpg")
            ref.putData(data, metadata: nil) { _, error in
                guard error == nil else {
                    uploadImageAndCreate(nil)
                    return
                }
                ref.downloadURL { url, _ in
                    uploadImageAndCreate(url?.absoluteString)
                }
            }
        } else {
            uploadImageAndCreate(nil)
        }
    }
}

