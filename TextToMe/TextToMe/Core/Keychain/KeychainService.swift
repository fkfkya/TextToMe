import Foundation
import Security

final class KeychainService {
    static let shared = KeychainService()
    private init() {}

    private let uuidKey = "userUUID"
    private let nicknameKey = "nickname"

    // MARK: - UUID

    func saveUUID(_ uuid: String) -> Bool {
        return save(uuid, for: uuidKey)
    }

    func getUUID() -> String? {
        return loadString(for: uuidKey)
    }

    func deleteUUID() {
        delete(key: uuidKey)
    }

    // MARK: - Nickname

    func saveNickname(_ nickname: String) -> Bool {
        return save(nickname, for: nicknameKey)
    }

    func getNickname() -> String? {
        return loadString(for: nicknameKey)
    }

    func deleteNickname() {
        delete(key: nicknameKey)
    }

    // MARK: - Generic save/load

    func save(_ string: String, for key: String) -> Bool {
        guard let data = string.data(using: .utf8) else { return false }
        return save(data, for: key)
    }

    func save(_ data: Data, for key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String  : data
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    func load(for key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String : true,
            kSecMatchLimit as String : kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    func loadString(for key: String) -> String? {
        guard let data = load(for: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
