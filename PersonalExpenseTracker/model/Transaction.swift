import UIKit
import CoreData

enum TransactionType: String,Codable {
    case expense
    case income
}

struct Transaction : Equatable, Codable{
    let id: UUID
    let type: TransactionType
    let category: Category
    let amount: String
    let date: Date
    let currency: String
    let info: String
}


extension Transaction {
    func toManagedObject(context: NSManagedObjectContext) -> TransactionDB? {
        guard let entity = NSEntityDescription.entity(forEntityName: "TransactionDB", in: context) else {
            return nil
        }
        
        let transactionDB = TransactionDB(entity: entity, insertInto: context)
        transactionDB.id = self.id
        transactionDB.type = self.type.rawValue
        transactionDB.categoryName = self.category.title
        transactionDB.amount = Double(self.amount) ?? 0.0
        transactionDB.currency = self.currency
        transactionDB.date = self.date
        transactionDB.info = self.info
        
        return transactionDB
    }
}


extension TransactionDB {
    func toTransaction(context:NSManagedObjectContext) -> Transaction? {
        guard let typeString = self.type,
              let id = self.id,
              let transactionType = TransactionType(rawValue: typeString),
              let categoryName = self.categoryName,
              let categoryDB = fetchCategory(named: categoryName,context:context),
              let currency = self.currency,
              let info = self.info,
              let date = self.date else {
            return nil
        }
        
        let amountString = String(format: "%.2f", self.amount) // Convert Double to String with format
        let category = categoryDB.toCategory()!
        
        return Transaction(id: id,type: transactionType, category: category, amount: amountString, date: date,currency: currency,info: info)
    }
    
    private func fetchCategory(named name: String, context: NSManagedObjectContext) -> CategoryDB? {
        let fetchRequest: NSFetchRequest<CategoryDB> = CategoryDB.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", name)
        
        do {
            let categories = try context.fetch(fetchRequest)
            return categories.first
        } catch {
            print("Failed to fetch category with name \(name): \(error)")
            return nil
        }
    }
}

