import Combine
import UIKit
import CoreData
import Foundation

class IncomeViewModel {
    @Published var incomes: [Transaction] = []
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
    
    init() {
        setupCDPublisher()
        observeCoreDataChanges()
    }
    
    func fetchTransactions() -> AnyPublisher<[Transaction], Error> {
            print("fetchTransactions called")
            let fetchRequest: NSFetchRequest<TransactionDB> = TransactionDB.fetchRequest()
            let typeOfTransaction = "income"  // Adjust as needed
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
    
    private func observeCoreDataChanges() {
          NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: coreDataManager.context)
              .sink { [weak self] _ in
                  self?.setupCDPublisher()
              }
              .store(in: &cancellables)
      }
    
    private func filterTransactions() {
        let now = Date()
        let calendar = Calendar.current
        let filteredIncomes: [Transaction]
        
        switch selectedTimePeriod {
        case .today:
            filteredIncomes = allTransactions.filter { calendar.isDateInToday($0.date) }
        case .weekly:
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            filteredIncomes = allTransactions.filter { $0.date >= startOfWeek }
        case .monthly:
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            filteredIncomes = allTransactions.filter { $0.date >= startOfMonth }
        case .yearly:
            let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
            filteredIncomes = allTransactions.filter { $0.date >= startOfYear }
        }
        
        self.incomes = filteredIncomes
        calculateCategoryGroups()
    }
    
    // Calculate the total amount of incomes
    func calculateCategoryGroups(){
        // Step 1: Convert string amounts to doubles and calculate total amount
        totalAmount = incomes.reduce(0.0) { total, transaction in
            if let amount = Double(transaction.amount) {
                return total + amount
            } else {
                // Handle invalid amounts if necessary
                return total
            }
        }
        
        // calculating total amount of eachCategoryGroup
        var categoryTotals: [Category: Double] = [:]
        
        for income in incomes {
            if let amount = Double(income.amount) {
                categoryTotals[income.category, default: 0.0] += amount
            }
        }
        print("categoryTotals count: \(categoryTotals.count)")
        
        // Step 3: Calculate category groups with percentage
        var newCategoryGroups: [CategoryGroup] = []
        
        for (category, amount) in categoryTotals {
            let percentage = (amount / totalAmount) * 100.0
            let group = CategoryGroup(category: category, totalAmount: amount, percentage: percentage)
            newCategoryGroups.append(group)
        }
        
        print("newCategoryGroups count: \(newCategoryGroups.count)")
        
        colorPercentageTuples = newCategoryGroups.map { group in
            ColorPercentageTuple(percentage: group.percentage, color: group.category.color)
        }
        
        self.categoryGroups = newCategoryGroups.sorted(by: { $0.totalAmount > $1.totalAmount })

        print("totalAmount->: \(totalAmount)")
    }
}
