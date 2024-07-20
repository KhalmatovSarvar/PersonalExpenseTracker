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
    
    // Indicates whether the transaction is an expense or income
    let isFromExpenses: Bool?
    private var transaction: Transaction?
    
    // Core Data manager instance
    private let coreDataManager = CoreDataManager.shared
    private let dataRepo = DataRepository()
    private var cancellables = Set<AnyCancellable>()
    private var cdPublisher: CDPublisher<CategoryDB>?
    
    init(isFromExpenses: Bool?, transaction: Transaction?) {
        self.isFromExpenses = isFromExpenses
        self.transaction = transaction
        self.category = transaction?.category
        
        if let transaction = transaction {
            self.amount = transaction.amount
            self.info = transaction.info
            self.date = transaction.date
        } else {
            self.amount = ""
            self.info = ""
        }
        
        fetchCategories()
    }


    func fetchCategories() {
        let fetchRequest: NSFetchRequest<CategoryDB> = CategoryDB.fetchRequest()
        cdPublisher = CDPublisher(request: fetchRequest, context: coreDataManager.context)
        
        cdPublisher?.map { categories -> [Category] in
                return categories.compactMap { $0.toCategory() }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                // Handle completion if needed
            }, receiveValue: { [weak self] convertedCategories in
                self?.categories = convertedCategories  // Assign the converted categories
                self?.isDataChanged = true  // Set the flag to indicate data change
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
    
    func updateTransaction() {
            guard let transaction = transaction, let category = category else {
                return
            }
        
        let newTransaction = Transaction(
            id: UUID(),
            type: transaction.type,
            category: category,
            amount: amount,
            date: date,
            currency: currency.rawValue,
            info: info
        )
            
            coreDataManager.updateTransactionCoreData(withId: transaction.id, newTransaction: newTransaction)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Transaction updated successfully")
                    case .failure(let error):
                        print("Failed to update transaction: \(error)")
                    }
                }, receiveValue: { _ in
                    // Handle any specific actions on success, if needed
                })
                .store(in: &cancellables)
        }
}
