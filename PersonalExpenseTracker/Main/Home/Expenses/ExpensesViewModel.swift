import Combine
import UIKit
import CoreData

enum TimePeriod: String, CaseIterable {
    case today
    case weekly
    case monthly
    case yearly
    
    var description: String {
        return self.rawValue
    }
}

class ExpensesViewModel {
    @Published var expenses: [Transaction] = []
    @Published var totalAmount: Double = 0.0
    @Published var categoryGroups: [CategoryGroup] = []
    @Published var colorPercentageTuples: [ColorPercentageTuple] = []
    
    var selectedTimePeriod: TimePeriod = .today {
        didSet {
            filterTransactions()
        }
    }
    
    private let coreDataManager = CoreDataManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var cdPublisher: CDPublisher<TransactionDB>?
    
    // New property to store all transactions
    private var allTransactions: [Transaction] = [] {
        didSet {
            filterTransactions()
        }
    }
    
    init(appDataSource: AppDataSource) {
        setupCDPublisher()
    }
    
    func fetchTransactions() -> AnyPublisher<[Transaction], Error> {
            print("fetchTransactions called")
            let fetchRequest: NSFetchRequest<TransactionDB> = TransactionDB.fetchRequest()
            let typeOfTransaction = "expense"  // Adjust as needed
            // Filter by type and sort by date
            fetchRequest.predicate = NSPredicate(format: "type == %@ AND amount > %@", argumentArray: [typeOfTransaction, 0])
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
            
            let cdPublisher = CDPublisher(request: fetchRequest, context: coreDataManager.context)
            
            return cdPublisher
                .map { transactions in
                    transactions.compactMap { $0.toTransaction(context: self.coreDataManager.context) }
                }
                .handleEvents(receiveSubscription: { _ in
                    print("fetchTransactions subscription received")
                }, receiveOutput: { output in
                    print("fetchTransactions output received: \(output.count) transactions")
                }, receiveCompletion: { completion in
                    print("fetchTransactions completion received: \(completion)")
                }, receiveCancel: {
                    print("fetchTransactions subscription canceled")
                })
                .eraseToAnyPublisher()
        }
        
        private func setupCDPublisher() {
            fetchTransactions()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    // Handle completion if needed
                    if case let .failure(error) = completion {
                        print("Failed to fetch transactions: \(error.localizedDescription)")
                    }
                }, receiveValue: { [weak self] fetchedTransactions in
                    self?.allTransactions = fetchedTransactions
                    print("Transactions count: \(self?.allTransactions.count ?? 0)")
                })
                .store(in: &cancellables)
        }
        

    
    private func filterTransactions() {
        let now = Date()
        let calendar = Calendar.current
        let filteredExpenses: [Transaction]
        
        switch selectedTimePeriod {
        case .today:
            filteredExpenses = allTransactions.filter { calendar.isDateInToday($0.date) }
        case .weekly:
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            filteredExpenses = allTransactions.filter { $0.date >= startOfWeek }
        case .monthly:
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            filteredExpenses = allTransactions.filter { $0.date >= startOfMonth }
        case .yearly:
            let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
            filteredExpenses = allTransactions.filter { $0.date >= startOfYear }
        }
        
        self.expenses = filteredExpenses
        calculateCategoryGroups()
    }
    
    // Calculate the total amount of expenses
    private func calculateCategoryGroups() {
        // Step 1: Convert string amounts to doubles and calculate total amount
        totalAmount = expenses.reduce(0.0) { total, transaction in
            if let amount = Double(transaction.amount) {
                return total + amount
            } else {
                // Handle invalid amounts if necessary
                return total
            }
        }
        
        // calculating total amount of eachCategoryGroup
        var categoryTotals: [Category: Double] = [:]
        
        for income in expenses {
            if let amount = Double(income.amount) {
                categoryTotals[income.category, default: 0.0] += amount
            }
        }
        
        // Step 3: Calculate category groups with percentage
        var newCategoryGroups: [CategoryGroup] = []
        
        for (category, amount) in categoryTotals {
            let percentage = (amount / totalAmount) * 100.0
            let group = CategoryGroup(category: category, totalAmount: amount, percentage: percentage)
            newCategoryGroups.append(group)
        }
        
        colorPercentageTuples = newCategoryGroups.map { group in
            ColorPercentageTuple(percentage: group.percentage, color: group.category.color)
        }
        
        self.categoryGroups = newCategoryGroups.sorted(by: { $0.totalAmount > $1.totalAmount })
    }
}
