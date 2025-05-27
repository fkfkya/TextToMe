import Foundation
import FirebaseFirestore

struct Message {
    let id: String
    let sender: String
    let text: String?
    let timestamp: Date
    let isMedia: Bool
    let mediaURL: String?
    let isDeleted: Bool
    let isReadBy: [String]

    init(id: String, data: [String: Any]) {
        self.id = id
        self.sender = data["sender"] as? String ?? ""
        self.text = data["text"] as? String
        self.timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
        self.isMedia = data["isMedia"] as? Bool ?? false
        self.mediaURL = data["mediaURL"] as? String
        self.isDeleted = data["isDeleted"] as? Bool ?? false
        self.isReadBy = data["isReadBy"] as? [String] ?? []
    }

    func toDictionary() -> [String: Any] {
        return [
            "sender": sender,
            "text": text ?? "",
            "timestamp": Timestamp(date: timestamp),
            "isMedia": isMedia,
            "mediaURL": mediaURL ?? "",
            "isDeleted": isDeleted,
            "isReadBy": isReadBy
        ]
    }
}
