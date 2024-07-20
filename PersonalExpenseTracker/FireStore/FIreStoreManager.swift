import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import CoreData
import Combine

class FirestoreManager {
    static let shared = FirestoreManager()
    private init() {}
    
    let db = Firestore.firestore()
    private var subscriptions = Set<AnyCancellable>()
    
    // Real-time listeners
    private var transactionsListener: ListenerRegistration?
    private var categoriesListener: ListenerRegistration?
    
    // Publisher for transactions
    func observeTransactionsFromFirestore(userId: String) -> AnyPublisher<[Transaction], Error> {
           let subject = PassthroughSubject<[Transaction], Error>()

           transactionsListener = db.collection("users").document(userId).collection("transactions")
               .addSnapshotListener { snapshot, error in
                   if let error = error {
                       subject.send(completion: .failure(error))
                   } else {
                       let transactions = snapshot?.documents.compactMap { document in
                           try? document.data(as: Transaction.self)
                       } ?? []
                       subject.send(transactions)
                   }
               }

           return subject
               .handleEvents(receiveCancel: {
                   self.transactionsListener?.remove()
               })
               .eraseToAnyPublisher()
       }
    
    
    func observeCategoriesFromFirestore(userId: String) -> AnyPublisher<[Category], Error> {
            let subject = PassthroughSubject<[Category], Error>()

            categoriesListener = db.collection("users").document(userId).collection("categories")
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        subject.send(completion: .failure(error))
                    } else {
                        let categories = snapshot?.documents.compactMap { document in
                            try? document.data(as: Category.self)
                        } ?? []
                        subject.send(categories)
                    }
                }

            return subject
                .handleEvents(receiveCancel: {
                    self.categoriesListener?.remove()
                })
                .eraseToAnyPublisher()
        }
    
    
    // Save user data to Firestore
    func saveUserFireStore(user: User, userData: [String: Any]) {
        db.collection("users").document(user.uid).setData(userData) { error in
            if let error = error {
                print("Error saving user: \(error.localizedDescription)")
            } else {
                print("User saved successfully")
                MyUserDefaults.shared.userID = user.uid
            }
        }
    }
    
    func fetchTransactionsOnceFromFireStore(userId: String) -> AnyPublisher<[Transaction], Error> {
        return Future<[Transaction], Error> { promise in
            let transactionRef = self.db.collection("users").document(userId).collection("transactions")
            
            transactionRef.getDocuments { querySnapshot, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                var transactions = [Transaction]()
                
                for document in querySnapshot!.documents {
                    do {
                        // Use optional binding to safely unwrap the result
                        let transaction = try document.data(as: Transaction.self)
                        transactions.append(transaction)
                        
                    } catch {
                        print("Error decoding transaction: \(error.localizedDescription)")
                    }
                }
                
                promise(.success(transactions))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchCategoriesOnceFromFireStore(userId: String) -> AnyPublisher<[Category], Error> {
        return Future<[Category], Error> { promise in
            let categoryRef = self.db.collection("users").document(userId).collection("categories")
            
            categoryRef.getDocuments { querySnapshot, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                var categories = [Category]()
                
                for document in querySnapshot!.documents {
                    do {
                        // Use optional binding to safely unwrap the result
                        let category = try document.data(as: Category.self)
                        categories.append(category)
                        
                    } catch {
                        print("Error decoding category: \(error.localizedDescription)")
                    }
                }
                
                promise(.success(categories))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func saveTransactionToFireStore(transaction: Transaction, userId: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            do {
                let transactionData = try Firestore.Encoder().encode(transaction)
                
                // Save to Firestore
                self.db.collection("users").document(userId).collection("transactions").document(transaction.id.uuidString).setData(transactionData) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    func updateTransactionFireStore(transaction: Transaction, userId: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            do {
                let transactionData = try Firestore.Encoder().encode(transaction)
                
                // Update in Firestore
                self.db.collection("users").document(userId).collection("transactions").document(transaction.id.uuidString).updateData(transactionData) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    func deleteTransactionFireStore(transactionId: String, userId: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            self.db.collection("users").document(userId).collection("transactions").document(transactionId).delete { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    func saveCategoryToFirestore(category: Category, userId: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            do {
                let categoryData = try Firestore.Encoder().encode(category)
                
                // Save to Firestore
                self.db.collection("users").document(userId).collection("categories").document(category.title).setData(categoryData) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    
    
    
    // Remove all listeners
    func removeListeners() {
        transactionsListener?.remove()
        categoriesListener?.remove()
    }
}
