import UIKit
import CoreData

struct Category: Hashable, Codable{
  
    
    let title: String
    @CodableColor var color: UIColor
    let icon: ImageWrapper
    
    // Custom implementation of equality
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.title == rhs.title
    }

    // Custom implementation of hashing
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}

extension Category {
    func toManagedObject(context: NSManagedObjectContext) -> CategoryDB? {
        guard let entity = NSEntityDescription.entity(forEntityName: "CategoryDB", in: context) else {
            return nil
        }
        
        let categoryDB = CategoryDB(entity: entity, insertInto: context)
        categoryDB.title = self.title
        if let colorData = try? JSONEncoder().encode(CodableColor(wrappedValue: self.color)) {
            categoryDB.color = colorData
        }
        if let iconData = try? JSONEncoder().encode(self.icon) {
            categoryDB.icon = iconData
        }
        
        return categoryDB
    }
}

extension CategoryDB {
    func toCategory() -> Category? {
        guard let title = self.title,
              let colorData = self.color,
              let codableColor = try? JSONDecoder().decode(CodableColor.self, from: colorData),
              let iconData = self.icon,
              let iconWrapper = try? JSONDecoder().decode(ImageWrapper.self, from: iconData) else {
            return nil
        }
        
        return Category(title: title, color: codableColor.wrappedValue, icon: iconWrapper)
    }
}
