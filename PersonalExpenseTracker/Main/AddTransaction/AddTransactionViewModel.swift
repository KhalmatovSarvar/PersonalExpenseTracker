import Combine
import Foundation
import CoreData

class AddTransactionViewModel {
    
    @Published var categories: [Category] = []
    @Published var isDataChanged: Bool = false
    
    var amount: String = "0.0"
    var currency: Currency = .USD
    var info: String = ""
    var category: Category? = nil
    var date: Date = Date()
    var id: UUID = UUID()
    
    // Indicates whether the transaction is an expense or income
    let isFromExpenses: Bool?
    private var transaction: Transaction?
    
    // Core Data manager instance
    private let coreDataManager = CoreDataManager.shared
    private let dataRepo = DataRepository()
    private var cancellables = Set<AnyCancellable>()
    
    init(isFromExpenses: Bool?, transaction: Transaction?) {
        self.isFromExpenses = isFromExpenses
        self.transaction = transaction
        self.category = transaction?.category
        
        if let transaction = transaction {
            self.amount = transaction.amount
            self.info = transaction.info
            self.date = transaction.date
            self.id = transaction.id
        } else {
            self.amount = ""
            self.info = ""
        }
        
        setupCDPublisherForCategories()
    }
    
    func fetchCategories() -> AnyPublisher<[Category], Error> {
        print("fetchCategories called")
        let fetchRequest: NSFetchRequest<CategoryDB> = CategoryDB.fetchRequest()
        fetchRequest.predicate = nil
        fetchRequest.sortDescriptors = []
        
        let cdPublisher = CDPublisher(request: fetchRequest, context: coreDataManager.context)
        
        return cdPublisher
            .map { categories in
                categories.compactMap { $0.toCategory() }
            }
            .handleEvents(receiveSubscription: { _ in
                print("fetchCategories subscription received")
            }, receiveOutput: { output in
                print("fetchCategories output received: \(output.count) categories")
            }, receiveCompletion: { completion in
                print("fetchCategories completion received: \(completion)")
            }, receiveCancel: {
                print("fetchCategories subscription canceled")
            })
            .eraseToAnyPublisher()
    }
    
    private func setupCDPublisherForCategories() {
        fetchCategories()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                // Handle completion if needed
                if case let .failure(error) = completion {
                    print("Failed to fetch categories: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] fetchedCategories in
                self?.categories = fetchedCategories
                self!.isDataChanged = true
                print("Categories count: \(self?.categories.count ?? 0)")
            })
            .store(in: &cancellables)
    }
    
    // Add a new transaction to Core Data
    func addTransaction() -> AnyPublisher<Void, Error> {
        guard let category = category,
              !amount.isEmpty,
              !info.isEmpty else {
            return Fail(error: NSError(domain: "AddTransactionViewModel", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid transaction data"]))
                .eraseToAnyPublisher()
        }
        
        let newTransaction = Transaction(
            id: UUID(),
            type: isFromExpenses! ? .expense : .income,
            category: category,
            amount: amount,
            date: date,
            currency: currency.rawValue,
            info: info
        )
        
        return dataRepo.saveTransaction(transaction: newTransaction)
    }
    
    func updateTransaction() -> AnyPublisher<Void, Error> {
        // Ensure required properties are set
        guard let type = transaction?.type,
              let category = category,
              let transaction = transaction
        else {
            return Fail(error: NSError(domain: "UpdateTransactionError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Missing required transaction information."]))
                .eraseToAnyPublisher()
        }
        
        // Create new transaction with validated values
        let updatedTransaction = Transaction(
            id: id,
            type: type,
            category: category,
            amount: amount,
            date: date,
            currency: currency.rawValue,
            info: info
        )
        
        print("Updated Transaction: \(updatedTransaction)")  // Debug print to see the updated transaction
        
        // Call the repository update method
        return dataRepo.updateTransaction(withId: transaction.id , newTransaction: updatedTransaction)
            .handleEvents(receiveCompletion: { completion in
                            switch completion {
                            case .finished:
                                print("Transaction update completed successfully.")
                            case .failure(let error):
                                print("Transaction update failed with error: \(error.localizedDescription)")
                            }
                        })
                        .eraseToAnyPublisher()
    }
    
}
