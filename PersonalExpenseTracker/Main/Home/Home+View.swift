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
        
        let expensesVC = ExpensesViewController()
        expensesVC.tabBarItem = UITabBarItem(title: "Expenses", image: nil, selectedImage: nil)
        
        let incomeVC = IncomeViewController()
        incomeVC.tabBarItem = UITabBarItem(title: "Income", image: nil, selectedImage: nil)
        
        viewControllers = [expensesVC, incomeVC]
    }
    
    private func setUpNavigationBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTransaction))
        let logOutButton = UIBarButtonItem(image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), style: .plain, target: self, action: #selector(logOutUser))
        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = logOutButton
    }
    
    @objc private func addTransaction() {
        let isFromExpenses = selectedViewController is ExpensesViewController
        let addTransactionVC = AddTransactionViewController(
            isFromExpenses: isFromExpenses,
            transaction: nil
        )
        self.navigationController?.pushViewController(addTransactionVC, animated: false)
    }
    
    @objc private func logOutUser() {
        
              
        viewModel.logOut()
            .sink(receiveCompletion: { completion in
                           switch completion {
                           case .finished:
                               // Handle successful logout
                               self.handleSuccessfulLogout()
                           case .failure(let error):
                               // Handle logout error
                               self.handleLogoutError(error)
                           }
                       }, receiveValue: {
                           // No value expected, just completion
                       })
                       .store(in: &cancellables)
        
        
        
             
    }
    
    private func handleSuccessfulLogout() {
        let signInViewController = SignInViewController()
         if let navigationController = self.navigationController {
             navigationController.setViewControllers([signInViewController], animated: true)
         } else {
             // If the view controller is not embedded in a navigation controller
             // Present the sign-in view controller modally
             let navigationController = UINavigationController(rootViewController: signInViewController)
             self.present(navigationController, animated: true, completion: nil)
         }
        }
        
    private func handleLogoutError(_ error: Error) {
        // Implement your logic for logout error, e.g., showing an error message
        print("Failed to log out: \(error.localizedDescription)")
        // Optionally, show an alert to the user
        let alert = UIAlertController(title: "Error", message: "Failed to log out: \(error.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
