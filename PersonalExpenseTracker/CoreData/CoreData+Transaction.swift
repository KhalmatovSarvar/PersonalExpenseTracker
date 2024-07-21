import CoreData
import Combine

// MARK: - CoreDataManager Extension

extension CoreDataManager {
    
    // MARK: - Save Transactions
    
    func saveTransactionToCoreData(transaction: Transaction) -> AnyPublisher<Void, Error> {
        let context = persistentContainer.viewContext
        
        return Future<Void, Error> { promise in
            context.perform {
                guard transaction.toManagedObject(context: context) != nil else {
                    promise(.failure(NSError(domain: "CoreDataManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to convert Transaction to TransactionDB"])))
                    return
                }
                
                self.saveContext(context)
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func saveTransactionsToCoreData(transactions: [Transaction]) -> AnyPublisher<Void, Error> {
        let saveTransactions = transactions.map { transaction in
            self.saveTransactionToCoreData(transaction: transaction)
        }
        
        return Publishers.MergeMany(saveTransactions)
            .collect()
            .tryMap { _ in }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Fetch Transactions
    
    func fetchTransactionsByTypeCoreData(transactionType: TransactionType) -> AnyPublisher<[Transaction], Error> {
        let fetchRequest: NSFetchRequest<TransactionDB> = TransactionDB.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "type == %@ AND amount != 0", transactionType.rawValue)
        
        return Future<[Transaction], Error> { promise in
            let context = self.persistentContainer.viewContext
            context.perform {
                do {
                    let results = try context.fetch(fetchRequest)
                    let transactions = results.compactMap { $0.toTransaction(context: context) }
                    promise(.success(transactions))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchAllTransactionsCoreData() -> AnyPublisher<[Transaction], Error> {
        let fetchRequest: NSFetchRequest<TransactionDB> = TransactionDB.fetchRequest()
        
        return Future<[Transaction], Error> { promise in
            let context = self.persistentContainer.viewContext
            context.perform {
                do {
                    let results = try context.fetch(fetchRequest)
                    let transactions = results.compactMap { $0.toTransaction(context: context) }
                    print(transactions)
                    promise(.success(transactions))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Update Transactions
    
    func updateTransactionCoreData(withId id: UUID, newTransaction: Transaction) -> AnyPublisher<Void, Error> {
        let context = persistentContainer.viewContext
        
        return Future<Void, Error> { promise in
            context.perform {
                let fetchRequest: NSFetchRequest<TransactionDB> = TransactionDB.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                
                do {
                    let results = try context.fetch(fetchRequest)
                    guard let transactionDB = results.first else {
                        throw NSError(domain: "UpdateError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Transaction with id \(id) not found."])
                    }
                    
                    // Update transactionDB with newTransaction values
                    transactionDB.id = newTransaction.id
                    transactionDB.type = newTransaction.type.rawValue
                    transactionDB.amount = Double(newTransaction.amount) ?? 0.0
                    transactionDB.date = newTransaction.date
                    transactionDB.categoryName = newTransaction.category.title
                    
                    print("Saving context...")
                    self.saveContext(context)
                    print("Context saved successfully.")
                    
                    promise(.success(()))
                } catch {
                    print("Error during fetch or save: \(error.localizedDescription)")
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateTransactionsToCoreData(transactions: [Transaction]) -> AnyPublisher<Void, Error> {
        let updateTransactions = transactions.map { transaction in
            self.updateTransactionCoreData(withId: transaction.id, newTransaction: transaction)
        }
        
        return Publishers.MergeMany(updateTransactions)
            .collect()
            .tryMap { _ in }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Delete Transactions
    
    func deleteTransactionCoreData(with id: UUID) -> AnyPublisher<Void, Error> {
        let fetchRequest: NSFetchRequest<TransactionDB> = TransactionDB.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "CoreDataManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Self is nil"])))
                return
            }
            
            context.perform {
                do {
                    let results = try self.context.fetch(fetchRequest)
                    for result in results {
                        self.context.delete(result)
                    }
                    try self.context.save()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteTransactionsFromCoreData(transactions: [Transaction]) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            self.context.perform {
                let fetchRequest: NSFetchRequest<TransactionDB> = TransactionDB.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id IN %@", transactions.map { $0.id })
                
                do {
                    let coreDataTransactions = try self.context.fetch(fetchRequest)
                    
                    for transaction in coreDataTransactions {
                        self.context.delete(transaction)
                    }
                    
                    try self.context.save()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
