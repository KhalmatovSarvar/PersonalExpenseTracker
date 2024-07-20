import UIKit
import CoreData
import Combine

class AddCategoryViewModel {
    @Published var categories = [Category]()
    var categoryName: String = ""
    var icon: String?
    var color: UIColor?
    
    private let coreDataManager = CoreDataManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var dataRepo = DataRepository()
    private var cdPublisher: CDPublisher<CategoryDB>?
    
    
    init(){
        
    }
    
    private func setupCategoryCDPublisher() {
        let fetchRequest: NSFetchRequest<CategoryDB> = CategoryDB.fetchRequest()
        
        fetchRequest.predicate = nil
          fetchRequest.sortDescriptors = []
        
        cdPublisher = CDPublisher(request: fetchRequest, context: coreDataManager.context)
        
        cdPublisher?.map { categories in
            categories.compactMap { $0.toCategory() }
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            // Handle completion if needed
        }, receiveValue: { [weak self] convertedCategories in
            self?.categories = convertedCategories
            print("categories count->: \(self?.categories.count ?? 0)")
            // Any additional operations needed for categories
        })
        .store(in: &cancellables)
    }

    
    
    
    func addCategory() -> AnyPublisher<Void, Error> {
        guard let icon = icon,
              let color = color,
              !categoryName.isEmpty else {
            return Fail(error: NSError(domain: "CategoryViewModel", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid category data"]))
                .eraseToAnyPublisher()
        }
        
        let newCategory = Category(title: categoryName, color: color, icon: ImageWrapper(image: UIImage(systemName: icon)!))
        
        return coreDataManager.saveCategoryToCoreData(category: newCategory)
    }}
