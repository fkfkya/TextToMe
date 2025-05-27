import Foundation

protocol AuthorizationInteractorProtocol {
    func checkIfUserExists(nickname: String, completion: @escaping (Bool) -> Void)
    func createUser(nickname: String, completion: @escaping (String) -> Void)
    func loginUser(nickname: String, uuid: String, completion: @escaping (Bool) -> Void)
}

final class AuthorizationInteractor: AuthorizationInteractorProtocol {
    
    private let usersKey = "users_map"
    
    func createUser(nickname: String, completion: @escaping (String) -> Void) {
        let uuid = UUID().uuidString

        var users = UserDefaults.standard.dictionary(forKey: usersKey) as? [String: String] ?? [:]
        guard users[nickname] == nil else {
            completion("ERROR")
            return
        }

        FirebaseService.shared.registerUser(nickname: nickname, uuid: uuid) { success in
            if success {
                users[nickname] = uuid
                UserDefaults.standard.setValue(users, forKey: self.usersKey)
                completion(uuid)
            } else {
                completion("ERROR")
            }
        }
    }
    
    func checkIfUserExists(nickname: String, completion: @escaping (Bool) -> Void) {
        FirebaseService.shared.checkIfUserExists(nickname: nickname) { exists in
            completion(exists)
        }
    }
    
    func loginUser(nickname: String, uuid: String, completion: @escaping (Bool) -> Void) {
        FirebaseService.shared.fetchUUID(for: nickname) { fetchedUUID in
            let isValid = fetchedUUID == uuid
            completion(isValid)
        }
    }
}
