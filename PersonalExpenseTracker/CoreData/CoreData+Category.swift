import CoreData
import Combine
import FirebaseFirestore
import UIKit

extension CoreDataManager {

    // MARK: - Save Category

    func saveCategoryToCoreData(category: Category) -> AnyPublisher<Void, Error> {
        let context = persistentContainer.viewContext
        
        guard category.toManagedObject(context: context) != nil else {
            return Fail(error: NSError(domain: "CoreDataManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to convert Category to CategoryDB"]))
                .eraseToAnyPublisher()
        }
        
        return Future<Void, Error> { promise in
            context.perform {
                do {
                    try context.save()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func saveCategoriesToCoreData(categories: [Category]) -> AnyPublisher<Void, Error> {
        let saveCategories = categories.map { category in
            self.saveCategoryToCoreData(category: category)
        }
        
        return Publishers.MergeMany(saveCategories)
            .collect()
            .tryMap { _ in }
            .eraseToAnyPublisher()
    }

    func fetchAllCategoriesCoreData() -> AnyPublisher<[Category], Error> {
        let fetchRequest: NSFetchRequest<CategoryDB> = CategoryDB.fetchRequest()
        
        return Future<[Category], Error> { promise in
            let context = self.persistentContainer.viewContext
            context.perform {
                do {
                    let results = try context.fetch(fetchRequest)
                    let categories = results.compactMap { $0.toCategory() }
                    promise(.success(categories))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Delete Category

    func deleteCategory(categoryDB: CategoryDB) -> AnyPublisher<Void, Error> {
        let context = self.persistentContainer.viewContext
        context.delete(categoryDB)
        
        return Future<Void, Error> { promise in
            context.perform {
                do {
                    try context.save()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateCategory(categoryDB: CategoryDB, with category: Category) -> AnyPublisher<Void, Error> {
        categoryDB.title = category.title
        
        // Encoding UIColor to Data using CodableColor
        if let colorData = try? JSONEncoder().encode(CodableColor(wrappedValue: category.color)) {
            categoryDB.color = colorData
        } else {
            return Fail(error: NSError(domain: "UpdateCategory", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode color"]))
                .eraseToAnyPublisher()
        }
        
        // Encoding UIImage to Data using ImageWrapper
        if let iconData = try? JSONEncoder().encode(category.icon) {
            categoryDB.icon = iconData
        } else {
            return Fail(error: NSError(domain: "UpdateCategory", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode icon"]))
                .eraseToAnyPublisher()
        }
        
        return Future<Void, Error> { promise in
            let context = self.persistentContainer.viewContext
            context.perform {
                do {
                    try context.save()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func deleteCategoriesFromCoreData(categories: [Category]) -> AnyPublisher<Void, Error> {
        let context = persistentContainer.viewContext
        
        return Future<Void, Error> { promise in
            context.perform {
                let fetchRequest: NSFetchRequest<CategoryDB> = CategoryDB.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "title IN %@", categories.map { $0.title })
                
                do {
                    let coreDataCategories = try context.fetch(fetchRequest)
                    
                    for category in coreDataCategories {
                        context.delete(category)
                    }
                    
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
