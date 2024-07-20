import UIKit
import Combine

class HomeViewController: UITabBarController {
    private var coreDataManager : CoreDataManager!
    private var appDataSource:AppDataSource!
    private var viewModel: HomeViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .blue
        return activityIndicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Main"
        coreDataManager = CoreDataManager()
        appDataSource = AppDataSource(coreDataManager: coreDataManager)

        
        setUpTabs()
        setUpNavigationBar()
        setUpLoading()
        
        viewModel = HomeViewModel()
        setUpBindings()
    }
    
    private func setUpLoading() {
        view.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setUpBindings() {
        viewModel.$isLoading
            .sink { [weak self] isLoading in
                isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
            }
            .store(in: &cancellables)
    
    }
    
    private func setUpTabs() {
        // Change tab bar item text attributes
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)], for: .selected)
        
        let expensesVC = ExpensesViewController(appDataSource: appDataSource)
        expensesVC.tabBarItem = UITabBarItem(title: "Expenses", image: nil, selectedImage: nil)
        
        let incomeVC = IncomeViewController()
        incomeVC.tabBarItem = UITabBarItem(title: "Income", image: nil, selectedImage: nil)
        
        viewControllers = [expensesVC, incomeVC]
    }
    
    private func setUpNavigationBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTransaction))
        navigationItem.rightBarButtonItem = addButton
    }
    
    @objc private func addTransaction() {
        let isFromExpenses = selectedViewController is ExpensesViewController
        let addTransactionVC = AddTransactionViewController(
            isFromExpenses: isFromExpenses,
            transaction: nil
        )
        self.navigationController?.pushViewController(addTransactionVC, animated: false)
    }
}
