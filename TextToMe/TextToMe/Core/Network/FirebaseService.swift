import Foundation
import FirebaseFirestore

final class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func checkIfUserExists(nickname: String, completion: @escaping (Bool) -> Void) {
        let docRef = db.collection("users").document(nickname)
        docRef.getDocument { snapshot, error in
            if let snapshot = snapshot, snapshot.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func fetchUUID(for nickname: String, completion: @escaping (String?) -> Void) {
        let docRef = db.collection("users").document(nickname)
        docRef.getDocument { snapshot, error in
            if let data = snapshot?.data(), let uuid = data["uuid"] as? String {
                completion(uuid)
            } else {
                completion(nil)
            }
        }
    }
    
    func registerUser(nickname: String, uuid: String, completion: @escaping (Bool) -> Void) {
        let docRef = db.collection("users").document(nickname)
        docRef.setData(["uuid": uuid]) { error in
            if let error = error {
                print("Firestore error: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }

}
