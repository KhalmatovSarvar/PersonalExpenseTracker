import UIKit
import CoreData
import Combine

class AddCategoryViewModel {
    @Published var categories = [Category]()
    var categoryName: String = ""
    var icon: String?
    var color: UIColor?
    
    private var cancellables = Set<AnyCancellable>()
    private var dataRepo = DataRepository()

    
    func addCategory() -> AnyPublisher<Void, Error> {
        guard let icon = icon,
              let color = color,
              !categoryName.isEmpty else {
            return Fail(error: NSError(domain: "CategoryViewModel", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid category data"]))
                .eraseToAnyPublisher()
        }
        
        let newCategory = Category(title: categoryName, color: color, icon: ImageWrapper(image: UIImage(systemName: icon)!))
        
        return dataRepo.saveCategory(category: newCategory)
    }}
