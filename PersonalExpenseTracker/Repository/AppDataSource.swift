import Combine
import CoreData

class AppDataSource: ObservableObject {
    private let coreDataManager: CoreDataManager
    private var cancellables = Set<AnyCancellable>()

    @Published var categories: [Category] = []
    @Published var transactions: [Transaction] = []

    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        print("AppDataSource initialized")
        initializeData()
    }

    func fetchCategories() -> AnyPublisher<[Category], Error> {
        print("fetchCategories called")
        let fetchRequest: NSFetchRequest<CategoryDB> = CategoryDB.fetchRequest()
        let cdPublisher = CDPublisher(request: fetchRequest, context: coreDataManager.context)

        return cdPublisher
            .map { categories -> [Category] in
                return categories.compactMap { $0.toCategory() }
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

    func fetchTransactions() -> AnyPublisher<[Transaction], Error> {
        print("fetchTransactions called")
        let fetchRequest: NSFetchRequest<TransactionDB> = TransactionDB.fetchRequest()
        let cdPublisher = CDPublisher(request: fetchRequest, context: coreDataManager.context)

        return cdPublisher
            .map { transactions -> [Transaction] in
                return transactions.compactMap { $0.toTransaction(context: self.coreDataManager.context) }
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

    private func initializeData() {
        print("initializeData called")
        fetchCategories()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error, context: "categories")
                }
            }, receiveValue: { [weak self] fetchedCategories in
                print("Categories fetched: \(fetchedCategories.count)")
                self?.categories = fetchedCategories
            })
            .store(in: &cancellables)

        fetchTransactions()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error, context: "transactions")
                }
            }, receiveValue: { [weak self] fetchedTransactions in
                print("Transactions fetched: \(fetchedTransactions.count)")
                self?.transactions = fetchedTransactions
            })
            .store(in: &cancellables)
    }

    private func handleError(_ error: Error, context: String) {
        print("Failed to fetch \(context): \(error.localizedDescription)")
    }

    // Other methods to interact with the database can be added here
}
