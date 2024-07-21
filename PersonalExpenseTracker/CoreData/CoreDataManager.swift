import Foundation
import UIKit
import CoreData
import FirebaseFirestore
import Combine

// MARK: - CoreDataManager

class CoreDataManager {
    // MARK: - Singleton
    
    static let shared = CoreDataManager()
    private init() {}
    
    // MARK: - Core Data Stack
    
    lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PersonalExpenseTracker")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    // MARK: - Core Data Queries
    
    func isTransactionsEmpty() -> Bool {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "TransactionDB")
        
        do {
            let count = try context.count(for: fetchRequest)
            return count == 0
        } catch {
            print("Error counting objects in Core Data: \(error)")
            return true // Treat error as empty database
        }
    }
    
    func isCategoriesEmpty() -> Bool {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CategoryDB")
        
        do {
            let count = try context.count(for: fetchRequest)
            return count == 0
        } catch {
            print("Error counting objects in Core Data: \(error)")
            return true // Treat error as empty database
        }
    }
    
    // MARK: - Data Management
    
    func clearAllData() -> AnyPublisher<Void, Error> {
        let entities = ["CategoryDB", "TransactionDB"] // Replace with your actual entity names
        
        let publishers: [AnyPublisher<Void, Error>] = entities.map { entityName in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            return Future { promise in
                do {
                    try self.context.execute(batchDeleteRequest)
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
            .eraseToAnyPublisher()
        }
        
        return Publishers.MergeMany(publishers)
            .collect()
            .flatMap { _ in
                Future { promise in
                    do {
                        try self.context.save()
                        promise(.success(()))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
            .eraseToAnyPublisher()
    }
    
    func saveContext(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
