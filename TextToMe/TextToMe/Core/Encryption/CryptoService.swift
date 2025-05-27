import Foundation
import CryptoKit

final class CryptoService {

    static let shared = CryptoService()

    private init() {}

    func encrypt(_ message: String, with key: SymmetricKey) -> String? {
        guard let data = message.data(using: .utf8) else { return nil }
        guard let sealed = try? AES.GCM.seal(data, using: key) else { return nil }
        return sealed.combined?.base64EncodedString()
    }

    func decrypt(_ base64: String, with key: SymmetricKey) -> String? {
        guard let data = Data(base64Encoded: base64),
              let sealed = try? AES.GCM.SealedBox(combined: data),
              let decrypted = try? AES.GCM.open(sealed, using: key)
        else {
            return nil
        }

        return String(data: decrypted, encoding: .utf8)
    }
}
