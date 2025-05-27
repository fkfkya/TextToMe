import Foundation
import FirebaseFirestore

final class ChatInteractor: ChatInteractorProtocol {

    weak var output: ChatInteractorOutput?

    private let chatId: String
    private let currentUser: String
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init(chatId: String, currentUser: String) {
        self.chatId = chatId
        self.currentUser = currentUser
    }

    func loadInitialMessages() {
        db.collection("chats")
            .document(chatId)
            .collection("messages")
            .order(by: "timestamp")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    self?.output?.didFail(with: "Ошибка загрузки: \(error.localizedDescription)")
                    return
                }

                guard let docs = snapshot?.documents else {
                    self?.output?.didFail(with: "Сообщения не найдены")
                    return
                }

                let messages = docs.compactMap { self?.decodeMessage(from: $0.data(), id: $0.documentID) }
                self?.output?.didLoadMessages(messages)
            }
    }

    func observeMessages() {
        listener = db.collection("chats")
            .document(chatId)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                guard let changes = snapshot?.documentChanges else { return }

                for change in changes where change.type == .added {
                    if let message = self.decodeMessage(from: change.document.data(), id: change.document.documentID) {
                        self.output?.didReceiveNewMessage(message)
                    }
                }
            }
    }

    func sendMessage(_ text: String) {
        let key = KeyManager.shared.getOrCreateKey(for: chatId)

        guard let encrypted = CryptoService.shared.encrypt(text, with: key) else {
            output?.didFail(with: "Ошибка шифрования сообщения")
            return
        }

        let data: [String: Any] = [
            "sender": currentUser,
            "text": encrypted,
            "timestamp": Timestamp(date: Date()),
            "isMedia": false,
            "isDeleted": false,
            "isReadBy": []
        ]

        db.collection("chats")
            .document(chatId)
            .collection("messages")
            .addDocument(data: data)
    }
    
    func sendMedia(data: Data, type: MediaType) {
        MediaService.shared.uploadEncryptedMedia(data: data, type: type, chatId: chatId) { [weak self] result in
            switch result {
            case .success(let urlString):
                let data: [String: Any] = [
                    "sender": self?.currentUser ?? "",
                    "text": "",
                    "timestamp": Timestamp(date: Date()),
                    "isMedia": true,
                    "mediaURL": urlString,
                    "isDeleted": false,
                    "isReadBy": []
                ]

                self?.db.collection("chats")
                    .document(self?.chatId ?? "")
                    .collection("messages")
                    .addDocument(data: data)

            case .failure(let error):
                self?.output?.didFail(with: "Ошибка медиа: \(error.localizedDescription)")
            }
        }
    }


    private func decodeMessage(from data: [String: Any], id: String) -> Message? {
        let key = KeyManager.shared.getOrCreateKey(for: chatId)

        var decryptedData = data

        if let encryptedText = data["text"] as? String,
           let decrypted = CryptoService.shared.decrypt(encryptedText, with: key) {
            decryptedData["text"] = decrypted
        } else {
            decryptedData["text"] = "[ошибка]"
        }

        return Message(id: id, data: decryptedData)
    }


    deinit {
        listener?.remove()
    }
}
