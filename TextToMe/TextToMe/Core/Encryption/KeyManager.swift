import Foundation
import CryptoKit

final class KeyManager {

    static let shared = KeyManager()

    private init() {}

    func getOrCreateKey(for chatId: String) -> SymmetricKey {
        if let data = KeychainService.shared.load(for: "key-\(chatId)") {
            return SymmetricKey(data: data)
        } else {
            let newKey = SymmetricKey(size: .bits256)
            let keyData = newKey.withUnsafeBytes { Data($0) }
            KeychainService.shared.save(keyData, for: "key-\(chatId)")
            return newKey
        }
    }
}

