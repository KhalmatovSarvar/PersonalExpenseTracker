import CoreData
import Combine
extension CoreDataManager {
    
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
        // Create a sequence of publishers for each transaction
        let saveTransactions = transactions.map { transaction in
            self.saveTransactionToCoreData(transaction: transaction)
        }
        
        // Use zip to combine all publishers into a single publisher
        return Publishers.Sequence(sequence: saveTransactions)
            .flatMap { $0 } // Flatten the output of each save transaction publisher
            .collect() // Collect all values into a single array
            .tryMap { _ in } // Transform output to Void
            .eraseToAnyPublisher()
    }
   
    
    
    
        // Fetch Transactions by type
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

        
        // Delete Transaction
        func deleteTransactionCoreData(transactionDB: TransactionDB) -> AnyPublisher<Void, Error> {
            let context = persistentContainer.viewContext
            
            return Future<Void, Error> { promise in
                context.perform {
                    context.delete(transactionDB)
                    self.saveContext(context)
                    promise(.success(()))
                }
            }
            .eraseToAnyPublisher()
        }
        
    // Update Transaction based on id
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
                    
                    self.saveContext(context)
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    
    func deleteTransactionCoreData(with id: UUID) -> AnyPublisher<Void, Error> {
            let fetchRequest: NSFetchRequest<TransactionDB> = TransactionDB.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            return Future<Void, Error> { [weak self] promise in
                guard let self = self else {
                    promise(.failure(NSError(domain: "CoreDataManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Self is nil"])))
                    return
                }
                
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
            .eraseToAnyPublisher()
        }
        
    
    // Save Context Helper
    private func saveContext(_ context: NSManagedObjectContext) {
        do {
            try context.save()
            print("Changes saved to Core Data successfully")
        } catch {
            print("Failed to save changes to Core Data: \(error.localizedDescription)")
        }
    }
    
    func deleteTransactionsFromCoreData(transactions: [Transaction]) -> AnyPublisher<Void, Error> {
          let context = persistentContainer.viewContext
          
          return Future<Void, Error> { promise in
              context.perform {
                  // Fetch existing Core Data transactions by IDs
                  let fetchRequest: NSFetchRequest<TransactionDB> = TransactionDB.fetchRequest()
                  fetchRequest.predicate = NSPredicate(format: "id IN %@", transactions.map { $0.id })
                  
                  do {
                      let coreDataTransactions = try context.fetch(fetchRequest)
                      
                      // Delete the fetched transactions
                      for transaction in coreDataTransactions {
                          context.delete(transaction)
                      }
                      
                      // Save the context
                      try context.save()
                      promise(.success(()))
                  } catch {
                      promise(.failure(error))
                  }
              }
          }
          .eraseToAnyPublisher()
      }
      
 
  }
