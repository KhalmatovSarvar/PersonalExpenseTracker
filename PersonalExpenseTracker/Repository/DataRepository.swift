import Foundation
import Combine

class DataRepository {
    private let coreDataManager: CoreDataManager
    private let firestoreManager: FirestoreManager
    let userID = MyUserDefaults.shared.userID
    
    private var cancellables = Set<AnyCancellable>()
    
    init(coreDataManager: CoreDataManager = CoreDataManager.shared,
         firestoreManager: FirestoreManager = FirestoreManager.shared) {
        self.coreDataManager = coreDataManager
        self.firestoreManager = firestoreManager
    }
    
    
    //MARK: - FETCHING AND SYNCING
    
    func fetchTransactionsFromFireStoreOnceAndSyncThenSaveToDB() -> AnyPublisher<[Transaction], Error> {
        return Future<[Transaction], Error> { promise in
            // Fetch transactions from Firestore
            self.firestoreManager.fetchTransactionsOnceFromFireStore(userId: self.userID!)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        promise(.failure(error))
                    case .finished:
                        print("Transaction fetching completed from Firestore")
                    }
                }, receiveValue: { firestoreTransactions in
                    print("Received transactions from Firestore: \(firestoreTransactions)")
                    
                    // Fetch transactions from Core Data
                    self.coreDataManager.fetchAllTransactionsCoreData()
                        .sink(receiveCompletion: { fetchCompletion in
                            if case .failure(let error) = fetchCompletion {
                                promise(.failure(error))
                            }
                        }, receiveValue: { coreDataTransactions in
                            // Compare Firestore transactions with Core Data transactions
                            let newTransactions = self.compareTransactions(firestoreTransactions, with: coreDataTransactions)
                            
                            // Save new transactions to Core Data
                            self.coreDataManager.saveTransactionsToCoreData(transactions: newTransactions)
                                .sink(receiveCompletion: { saveCompletion in
                                    switch saveCompletion {
                                    case .failure(let error):
                                        promise(.failure(error))
                                    case .finished:
                                        promise(.success(firestoreTransactions))
                                    }
                                }, receiveValue: { _ in })
                                .store(in: &self.cancellables)
                        })
                        .store(in: &self.cancellables)
                })
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    
    func fetchCategoriesFromFireStoreOnceAndSyncThenSaveToDB() -> AnyPublisher<[Category], Error> {
        return Future<[Category], Error> { promise in
            // Fetch categories from Firestore
            self.firestoreManager.fetchCategoriesOnceFromFireStore(userId: self.userID!)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        promise(.failure(error))
                    case .finished:
                        print("Category fetching completed from Firestore")
                    }
                }, receiveValue: { firestoreCategories in
                    print("Received categories from Firestore: \(firestoreCategories)")
                    
                    // Fetch categories from Core Data
                    self.coreDataManager.fetchAllCategoriesCoreData()
                        .sink(receiveCompletion: { fetchCompletion in
                            if case .failure(let error) = fetchCompletion {
                                promise(.failure(error))
                            }
                        }, receiveValue: { coreDataCategories in
                            // Compare Firestore categories with Core Data categories
                            let newCategories = self.compareCategories(firestoreCategories, with: coreDataCategories)
                            
                            // Save new categories to Core Data
                            self.coreDataManager.saveCategoriesToCoreData(categories: newCategories)
                                .sink(receiveCompletion: { saveCompletion in
                                    switch saveCompletion {
                                    case .failure(let error):
                                        promise(.failure(error))
                                    case .finished:
                                        promise(.success(firestoreCategories))
                                    }
                                }, receiveValue: { _ in })
                                .store(in: &self.cancellables)
                        })
                        .store(in: &self.cancellables)
                })
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    // Helper method to compare transactions and return only new ones
    private func compareTransactions(_ firestoreTransactions: [Transaction], with coreDataTransactions: [Transaction]) -> [Transaction] {
        let firestoreTransactionIDs = Set(firestoreTransactions.map { $0.id })
        let coreDataTransactionIDs = Set(coreDataTransactions.map { $0.id })
        
        // Filter out transactions that are not in Core Data
        let newTransactionIDs = firestoreTransactionIDs.subtracting(coreDataTransactionIDs)
        
        // Extract new transactions from Firestore based on IDs
        let newTransactions = firestoreTransactions.filter { newTransactionIDs.contains($0.id) }
        
        return newTransactions
    }
    
    // Helper method to compare categories and return only new ones
    private func compareCategories(_ firestoreCategories: [Category], with coreDataCategories: [Category]) -> [Category] {
        let firestoreCategoryTitles = Set(firestoreCategories.map { $0.title })
        let coreDataCategoryTitles = Set(coreDataCategories.map { $0.title })
        
        // Filter out categories that are not in Core Data
        let newCategoryTitles = firestoreCategoryTitles.subtracting(coreDataCategoryTitles)
        
        // Extract new categories from Firestore based on titles
        let newCategories = firestoreCategories.filter { newCategoryTitles.contains($0.title) }
        
        return newCategories
    }
    
    
    //MARK: - SAVING
    
    func saveTransaction(transaction: Transaction) -> AnyPublisher<Void, Error> {
        return coreDataManager.saveTransactionToCoreData(transaction: transaction)
            .flatMap { _ -> AnyPublisher<Void, Error> in
                // If saving to Core Data succeeds, proceed to save to Firestore
                return self.firestoreManager.saveTransactionToFireStore(transaction: transaction, userId: self.userID!)            }
            .eraseToAnyPublisher()
    }
    
    //MARK: - SAVING
    
    func saveCategory(category: Category) -> AnyPublisher<Void, Error> {
        return coreDataManager.saveCategoryToCoreData(category: category)
            .flatMap { _ -> AnyPublisher<Void, Error> in
                // If saving to Core Data succeeds, proceed to save to Firestore
                return self.firestoreManager.saveCategoryToFirestore(category: category, userId: self.userID!)            }
            .eraseToAnyPublisher()
    }

    
    func synchronizeTransactionsFromFirestore() -> AnyPublisher<Void, Error> {
        return firestoreManager.observeTransactionsFromFirestore(userId: userID!)
            .flatMap { [weak self] firestoreTransactions -> AnyPublisher<Void, Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "CoreDataManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "Self is nil"]))
                        .eraseToAnyPublisher()
                }
                
                return coreDataManager.fetchAllTransactionsCoreData()
                    .tryMap { coreDataTransactions -> (new: [Transaction], toDelete: [Transaction], toUpdate: [Transaction]) in
                        // Determine new, outdated, and updated transactions
                        let firestoreTransactionIDs = Set(firestoreTransactions.map { $0.id })
                        let coreDataTransactionIDs = Set(coreDataTransactions.map { $0.id })
                        
                        let newTransactionIDs = firestoreTransactionIDs.subtracting(coreDataTransactionIDs)
                        let transactionsToDeleteIDs = coreDataTransactionIDs.subtracting(firestoreTransactionIDs)
                        let transactionsToUpdateIDs = firestoreTransactionIDs.intersection(coreDataTransactionIDs)
                        
                        let newTransactions = firestoreTransactions.filter { newTransactionIDs.contains($0.id) }
                        let transactionsToDelete = coreDataTransactions.filter { transactionsToDeleteIDs.contains($0.id) }
                        let transactionsToUpdate = coreDataTransactions.filter { transactionsToUpdateIDs.contains($0.id) }
                        
                        // Filter transactions to update
                        let updatedTransactions = firestoreTransactions.filter { firestoreTransaction in
                            if let coreDataTransaction = coreDataTransactions.first(where: { $0.id == firestoreTransaction.id }) {
                                return firestoreTransaction != coreDataTransaction
                            }
                            return false
                        }
                        
                        return (new: newTransactions, toDelete: transactionsToDelete, toUpdate: updatedTransactions)
                    }
                    .flatMap { (newTransactions, toDeleteTransactions, toUpdateTransactions) -> AnyPublisher<Void, Error> in
                        // Perform batch update: add new, update existing, and delete old transactions
                        let addPublisher = self.coreDataManager.saveTransactionsToCoreData(transactions: newTransactions)
                        let updatePublisher = self.coreDataManager.updateTransactionsToCoreData(transactions: toUpdateTransactions)
                        let deletePublisher = self.coreDataManager.deleteTransactionsFromCoreData(transactions: toDeleteTransactions)
                        
                        return Publishers.MergeMany(addPublisher, updatePublisher, deletePublisher)
                            .collect()
                            .map { _ in () } // Combine the results into a single publisher
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    
    
    
    func synchronizeCategoriesFromFirestore() -> AnyPublisher<Void, Error> {
        return firestoreManager.observeCategoriesFromFirestore(userId: userID!)
            .flatMap { [weak self] firestoreCategories -> AnyPublisher<Void, Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "CoreDataManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "Self is nil"]))
                        .eraseToAnyPublisher()
                }
                
                return coreDataManager.fetchAllCategoriesCoreData()
                    .tryMap { coreDataCategories -> (new: [Category], toDelete: [Category]) in
                        // Determine new and outdated categories
                        let firestoreCategoryTitles = Set(firestoreCategories.map { $0.title })
                        let coreDataCategoryTitles = Set(coreDataCategories.map { $0.title })
                        
                        let newCategoryTitles = firestoreCategoryTitles.subtracting(coreDataCategoryTitles)
                        let categoriesToDeleteTitles = coreDataCategoryTitles.subtracting(firestoreCategoryTitles)
                        
                        let newCategories = firestoreCategories.filter { newCategoryTitles.contains($0.title) }
                        let categoriesToDelete = coreDataCategories.filter { categoriesToDeleteTitles.contains($0.title) }
                        
                        return (new: newCategories, toDelete: categoriesToDelete)
                    }
                    .flatMap { (newCategories, toDeleteCategories) -> AnyPublisher<Void, Error> in
                        // Perform batch update: add new and delete old categories
                        let addPublisher = self.coreDataManager.saveCategoriesToCoreData(categories: newCategories)
                        let deletePublisher = self.coreDataManager.deleteCategoriesFromCoreData(categories: toDeleteCategories)
                        
                        return Publishers.Merge(addPublisher, deletePublisher)
                            .collect()
                            .map { _ in () } // Combine the results into a single publisher
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    
    func checkTransactionIsEmpty()->Bool{
        return coreDataManager.isTransactionsEmpty()
    }
    
    func checkCategoryIsEmpty()->Bool{
        return coreDataManager.isCategoriesEmpty()
    }
    
    func deleteTransaction(with id: UUID) -> AnyPublisher<Void, Error> {
        coreDataManager.deleteTransactionCoreData(with: id)
            .flatMap { [weak self] _ -> AnyPublisher<Void, Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Self is nil"]))
                        .eraseToAnyPublisher()
                }
                return firestoreManager.deleteTransactionFireStore(transactionId: id.uuidString, userId: userID!)
            }
            .eraseToAnyPublisher()
    }
    
    


    func updateTransaction(withId id: UUID, newTransaction transaction: Transaction) -> AnyPublisher<Void, Error> {
        // Perform Core Data update
        let coreDataUpdatePublisher = coreDataManager.updateTransactionCoreData(withId: id, newTransaction: transaction)
        
        // Perform Firestore update
        let firestoreUpdatePublisher = firestoreManager.updateTransactionFireStore(transaction: transaction, userId: self.userID!)
        
        // Combine both publishers
        return Publishers.Zip(coreDataUpdatePublisher, firestoreUpdatePublisher)
            .map { _ in () } // Combine results into a single Void result
            .eraseToAnyPublisher()
    }
    
    
    func clearUserData()->AnyPublisher<Void,Error>{
        let defaults = MyUserDefaults.shared
        defaults.isUserSignedIn = false
        defaults.isUserSignedUp = false
        defaults.userEmail = ""
        defaults.userID = nil
        defaults.userName = ""
        
        return coreDataManager.clearAllData()
    }

    
    
    
    
    
    func addInitialCategories()->AnyPublisher<Void, Error>{
        let initialCategories = AppDataSource.shared.initialCategories
        
        return coreDataManager.saveCategoriesToCoreData(categories: initialCategories)
            .flatMap { _ -> AnyPublisher<Void, Error> in
                // If saving to Core Data succeeds, proceed to save to Firestore
                return self.firestoreManager.saveCategoriesToFirestore(categories: initialCategories, userId: self.userID!)
            }
            .eraseToAnyPublisher()
        
    }
    
}
