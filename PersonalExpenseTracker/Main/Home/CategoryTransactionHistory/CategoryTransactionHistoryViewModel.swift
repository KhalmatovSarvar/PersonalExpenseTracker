import Combine
import CoreData
import Foundation

class CategoryTransactionHistoryViewModel {
    @Published var transactions: [Transaction] = []
    @Published var totalAmount: Double = 0.0
    @Published var isLoading: Bool = false
    
    
    private let coreDataManager = CoreDataManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var dataRepo = DataRepository()
    private var cdPublisher: CDPublisher<TransactionDB>?
    
    // New property to store all transactions
    private var allTransactions: [Transaction] = []
    var categoryName: String
    var isFromExpenses: Bool
    
    init(categoryName: String,isFromExpenses: Bool) {
        self.categoryName = categoryName
        self.isFromExpenses = isFromExpenses
        setupCDPublisher()
    }
    
    private func setupCDPublisher() {
        let fetchRequest: NSFetchRequest<TransactionDB> = TransactionDB.fetchRequest()
        let typeOfTransaction = isFromExpenses ? "expense" : "income"
        // Filter by categoryName and sort by date
        fetchRequest.predicate = NSPredicate(format: "type == %@ AND amount > %@ AND categoryName == %@", argumentArray: [typeOfTransaction, 0, categoryName])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        cdPublisher = CDPublisher(request: fetchRequest, context: coreDataManager.context)
        
        cdPublisher?.map { transactions in
            transactions.compactMap { $0.toTransaction(context: self.coreDataManager.context) }
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            // Handle completion if needed
        }, receiveValue: { [weak self] convertedTransactions in
            self?.transactions = convertedTransactions
            print("transactions count->: \(self?.transactions.count ?? 0)")
            self?.calculateTotal()
        })
        .store(in: &cancellables)
    }
    
    // Calculate the total amount of transactions
    func calculateTotal() {
        // Convert string amounts to doubles and calculate total amount
        totalAmount = transactions.reduce(0.0) { total, transaction in
            if let amount = Double(transaction.amount) {
                return total + amount
            } else {
                // Handle invalid amounts if necessary
                return total
            }
        }
        print("totalAmount->: \(totalAmount)")
    }
    
    func deleteTransaction(with id: UUID) -> AnyPublisher<Void, Error> {
        dataRepo.deleteTransaction(with: id)
    }
    
}
