import Foundation
import UIKit
import CoreData
import FirebaseFirestore
import Combine

class CoreDataManager {
    static let shared = CoreDataManager()
    lazy var context: NSManagedObjectContext = {
          return persistentContainer.viewContext
      }()
         init() {}
        
        lazy var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "PersonalExpenseTracker")
            container.loadPersistentStores { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
            return container
        }()
        
 
    
    // Generic Save Entity
        func saveEntity<T: NSManagedObject>(_ entity: T) -> AnyPublisher<Void, Error> {
            let context = persistentContainer.viewContext
            
            return Future<Void, Error> { promise in
                context.insert(entity)
                self.saveContext(context)
                promise(.success(()))
            }
            .eraseToAnyPublisher()
        }
        
        
        // Generic Delete Entity
        func deleteEntity<T: NSManagedObject>(_ entity: T) -> AnyPublisher<Void, Error> {
            let context = persistentContainer.viewContext
            context.delete(entity)
            
            return Future<Void, Error> { promise in
                self.saveContext(context)
                promise(.success(()))
            }
            .eraseToAnyPublisher()
        }
        
        // Generic Update Entity
        func updateEntity<T: NSManagedObject>(_ entity: T) -> AnyPublisher<Void, Error> {
            let context = persistentContainer.viewContext
            
            return Future<Void, Error> { promise in
                self.saveContext(context)
                promise(.success(()))
            }
            .eraseToAnyPublisher()
        }
    
    
    func isTransactionsEmpty() -> Bool {
           let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "TransactionDB")
           let context = persistentContainer.viewContext
           
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
           let context = persistentContainer.viewContext
           
           do {
               let count = try context.count(for: fetchRequest)
               return count == 0
           } catch {
               print("Error counting objects in Core Data: \(error)")
               return true // Treat error as empty database
           }
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



