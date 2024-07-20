import UIKit
import Combine

class CategoryTransactionHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var uniqueDates: [Date] = []
    var categoryTransactions: [Transaction] = []
    private var cancellables = Set<AnyCancellable>()
    
    
    private let allAmountLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemBackground
        label.font = UIFont.systemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .appText // Adjust text color as needed
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var messageLabel:UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemBackground
        label.font = UIFont.systemFont(ofSize: 28)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .appText // Adjust text color as needed
        return label
    }()
    
    private var viewModel: CategoryTransactionHistoryViewModel
    
    init(categoryName: String, isFromExpenses: Bool) {
        self.viewModel = CategoryTransactionHistoryViewModel(categoryName: categoryName,isFromExpenses: isFromExpenses)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupView()
        setUpBindings()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.addSubview(allAmountLabel)
        view.addSubview(tableView)
        view.addSubview(messageLabel)
        
        tableView.dataSource = self
        tableView.delegate = self
//        tableView.isEditing = true
        tableView.register(CategoryTransactionViewCell.self, forCellReuseIdentifier: CategoryTransactionViewCell.reuseIdentifier)
        
        NSLayoutConstraint.activate([
            allAmountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            allAmountLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            allAmountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: allAmountLabel.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setUpBindings(){
        viewModel.$transactions
                .sink { [weak self] transactions in
                    if transactions.isEmpty {
                        self?.messageLabel.isHidden = false
                        self?.messageLabel.text = "No transaction available"
                        self?.categoryTransactions = []
                    } else {
                        self?.messageLabel.isHidden = true
                        self?.categoryTransactions = transactions.sorted(by: { $0.date < $1.date })
                    }
                    self?.tableView.reloadData()
                }
                .store(in: &cancellables)
        
        viewModel.$totalAmount
            .sink { [weak self] totalAmount in
                self?.allAmountLabel.text = "$\(totalAmount)"
            }
            .store(in: &cancellables)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        uniqueDates = Array(Set(categoryTransactions.map { Calendar.current.startOfDay(for: $0.date) })).sorted()
        return uniqueDates.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionDate = uniqueDates[section]
        let transactionsInSection = categoryTransactions.filter { Calendar.current.startOfDay(for: $0.date) == sectionDate }
        return transactionsInSection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTransactionViewCell.reuseIdentifier, for: indexPath) as! CategoryTransactionViewCell
        let sectionDate = uniqueDates[indexPath.section]
        let transactionsInSection = categoryTransactions.filter { Calendar.current.startOfDay(for: $0.date) == sectionDate }
        cell.configure(with: transactionsInSection[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let date = uniqueDates[section]
        return dateFormatter.string(from: date)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionDate = uniqueDates[indexPath.section]
        let transactionsInSection = viewModel.transactions.filter { Calendar.current.startOfDay(for: $0.date) == sectionDate }
        
        guard transactionsInSection.indices.contains(indexPath.row) else {
            print("Invalid row")
            return
        }
        
        let transaction = transactionsInSection[indexPath.row]
        print("transaction: \(transaction.amount)")
        print("section: \(indexPath.section)")
        print("row: \(indexPath.row)")
        
        let vc = TransactionDetailViewController(transaction: transaction)
        self.navigationController?.pushViewController(vc, animated: true)
    }



    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            guard let self = self else {
                completion(false)
                return
            }

            let sectionDate = self.uniqueDates[indexPath.section]
            let transactionsInSection = self.viewModel.transactions.filter { Calendar.current.startOfDay(for: $0.date) == sectionDate }
            let transactionToDelete = transactionsInSection[indexPath.row]

            self.viewModel.deleteTransaction(with: transactionToDelete.id)
                .sink(receiveCompletion: { completionResult in
                    switch completionResult {
                    case .finished:
                        // Update local data source
                        if let index = self.viewModel.transactions.firstIndex(of: transactionToDelete) {
                            self.viewModel.transactions.remove(at: index)
                        }

                        // Update uniqueDates if needed
                        let remainingTransactionsInSection = self.viewModel.transactions.filter { Calendar.current.startOfDay(for: $0.date) == sectionDate }
                        if remainingTransactionsInSection.isEmpty {
                            if let sectionIndex = self.uniqueDates.firstIndex(of: sectionDate) {
                                self.uniqueDates.remove(at: sectionIndex)
                            }
                        }

                        // Reload table view
                        self.tableView.reloadData()

                        // Call completion handler to indicate action is complete
                        completion(true)
                    case .failure(let error):
                        // Handle error
                        print("Failed to delete transaction: \(error)")
                        completion(false)
                    }
                }, receiveValue: { })
                .store(in: &self.cancellables)
        }
        
        deleteAction.backgroundColor = UIColor.red
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }






}
