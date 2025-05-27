import Foundation
import CoreMedia
import FirebaseStorage
import CryptoKit

final class MediaService {

    static let shared = MediaService()
    private init() {}

    func uploadEncryptedMedia(data: Data,
                              type: MediaType,
                              chatId: String,
                              completion: @escaping (Result<String, Error>) -> Void) {

        let key = KeyManager.shared.getOrCreateKey(for: chatId)

        // Шифруем
        guard let sealed = try? AES.GCM.seal(data, using: key),
              let encrypted = sealed.combined else {
            completion(.failure(MediaError.encryptionFailed))
            return
        }

        let filename = UUID().uuidString + "." + type.fileExtension
        let ref = Storage.storage().reference().child("chats/\(chatId)/media/\(filename)")

        ref.putData(encrypted, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            ref.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url.absoluteString))
                }
            }
        }
    }

    func decryptMedia(from data: Data, chatId: String) -> Data? {
        let key = KeyManager.shared.getOrCreateKey(for: chatId)
        guard let sealed = try? AES.GCM.SealedBox(combined: data),
              let decrypted = try? AES.GCM.open(sealed, using: key) else {
            return nil
        }
        return decrypted
    }

    enum MediaError: Error {
        case encryptionFailed
    }
}
