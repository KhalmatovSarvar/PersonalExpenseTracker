import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthService {
    
    static let shared = AuthService() // Singleton instance
    
    private let db = Firestore.firestore()
    
    func signUp(name: String, age: Int, email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let user = authResult?.user {
                let userData: [String: Any] = [
                    "name": name,
                    "email": email,
                    "age": age
                ]
                self.db.collection("users").document(user.uid).setData(userData) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(user))
                        MyUserDefaults.shared.userID = user.uid
                    }
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let user = authResult?.user {
                MyUserDefaults.shared.userID = user.uid
                completion(.success(user))
            } else if let error = error {
                completion(.failure(error))
               
            }
        }
    }
    
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
            MyUserDefaults.shared.userID = nil
        } catch {
            completion(.failure(error))
        }
    }
}
