import UIKit
import Combine


class IncomeViewController: UIViewController {
    var viewModel = IncomeViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    let periodButton = UIButton(primaryAction: nil)
    
    
    init(){
        super.init(nibName: nil, bundle: nil)
        viewModel = IncomeViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let totalBudgetLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.text = "Total Budget: $1000000000"
        return label
    }()
    
    
    private let categoryGroupTableView: CategoryGroupTableView = {
        let tableView = CategoryGroupTableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        categoryGroupTableView.delegate = self
        
        
        setUpView()
        setupDropDownButton()
        setUpActions()
        bindViewModel()
    }
    
    private func bindViewModel(){
        Publishers.CombineLatest3(
                    viewModel.$totalAmount,
                    viewModel.$categoryGroups,
                    viewModel.$colorPercentageTuples
                )
                .sink { [weak self] totalAmount, categoryGroups, colorPercentageTuples in
                    // Handle UI update with latest values
                    self?.updateUI(donutChartData: colorPercentageTuples, categoryGroups: categoryGroups)
                    self?.totalBudgetLabel.text = "$\(totalAmount)"
                }
                .store(in: &cancellables)
        }
    
    
    private func setUpActions(){}
    
    func setupDropDownButton() {
        periodButton.translatesAutoresizingMaskIntoConstraints = false
        var menuChildren: [UIMenuElement] = []
        let dataSource = TimePeriod.allCases.map { $0.description }
        
        // Ensure dataSource is not empty
        guard !dataSource.isEmpty else {
            return
        }
        
        // Create UIActions for each currency
        for period in dataSource {
            let action = UIAction(title: period) { [weak self] action in
                guard let self = self else { return }
                self.viewModel.selectedTimePeriod = TimePeriod(rawValue: action.title)!
                print("Selected period: \(action.title)")
            }
            menuChildren.append(action)
        }
        
        // Check if menuChildren is not empty before assigning to UIMenu
        guard !menuChildren.isEmpty else {
            return
        }
        
        periodButton.menu = UIMenu(options: .displayInline, children: menuChildren)
        periodButton.showsMenuAsPrimaryAction = true
        periodButton.changesSelectionAsPrimaryAction = true
    }
    
    private func setUpView(){
        view.addSubview(categoryGroupTableView)
        view.addSubview(totalBudgetLabel)
        view.addSubview(periodButton)
        
        setUpConstraints()
    }
    
    private func setUpConstraints(){
        
        NSLayoutConstraint.activate([
            totalBudgetLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60), // Adjust leading margin as needed
            totalBudgetLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60), // Adjust trailing margin as needed
            totalBudgetLabel.heightAnchor.constraint(equalToConstant: 30),
            
            periodButton.topAnchor.constraint(equalTo: totalBudgetLabel.bottomAnchor,constant: 8),
            periodButton.centerXAnchor.constraint(equalTo: totalBudgetLabel.centerXAnchor),
            periodButton.heightAnchor.constraint(equalToConstant: 30),
            
            categoryGroupTableView.topAnchor.constraint(equalTo: periodButton.bottomAnchor,constant: 5),
            categoryGroupTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryGroupTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryGroupTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            totalBudgetLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0), //
        ])
    }
    
    private func updateUI(donutChartData:[ColorPercentageTuple],categoryGroups:[CategoryGroup]) {
        categoryGroupTableView.setupData(donutChartData: donutChartData, categoryGroups: categoryGroups)
    }
    
}


extension IncomeViewController: CategoryGroupTableViewDelegate {
    func didSelectTransaction(_ categoryGroup: CategoryGroup) {
        let categoryName = categoryGroup.category.title // Assuming categoryGroup has a property `category`
        let categoryTransactionHistoryVC = CategoryTransactionHistoryViewController(categoryName: categoryName,isFromExpenses: false)
        navigationController?.pushViewController(categoryTransactionHistoryVC, animated: true)
    }
}



