import UIKit
import Combine

enum Currency: String, CaseIterable {
    case USD
    case RUB
    case UZS
    
    var description: String {
        return self.rawValue
    }
}

class AddTransactionViewController: UIViewController {
    var viewModel: AddTransactionViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    init(isFromExpenses: Bool?, transaction: Transaction?) {
        super.init(nibName: nil, bundle: nil)
        print("isFromExpenses: \(String(describing: isFromExpenses)) in init")
        viewModel = AddTransactionViewModel(isFromExpenses: isFromExpenses, transaction: transaction)
        
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    var categoryCollectionView: UICollectionView!
    let currencyButton = UIButton(primaryAction: nil)
    
    var screenWidth = 0.0;
    
    
    
    
    
    let addButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    
    
   
    
    let todayButton = UIButton()
    let twoDaysAgoButton = UIButton()
    let yesterdayButton = UIButton()
    let calendarButton = UIButton()
    let calendarView = UIDatePicker()
    let amountTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .decimalPad
        textField.layer.cornerRadius = 10
        textField.isUserInteractionEnabled = true
        textField.textColor = .black // Adjust color as needed
        textField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        // Add left padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.placeholder = "Amount"
        return textField
    }()
    let descriptionTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .default
        textField.layer.cornerRadius = 10
        textField.isUserInteractionEnabled = true
        textField.textColor = .appText// Adjust color as needed
        textField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        // Add left padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.placeholder = "Description"
        return textField
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if viewModel.isFromExpenses != nil {
            self.title = viewModel.isFromExpenses! ? "Add Expense" : "Add Income"
            addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
            
        }else{
            self.title = "Edit trnsaction"
            addButton.setTitle("Edit", for: .normal)
            addButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        }
        
        setupViews()
        setUpBindings()
        let currencyRateButton = UIBarButtonItem( image: UIImage(systemName: "dollarsign.arrow.circlepath"), style: .plain, target: self, action: #selector(navigateCurrencyRateVC))
        navigationItem.rightBarButtonItem = currencyRateButton
    }
    
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        categoryCollectionView.invalidateIntrinsicContentSize()
        categoryCollectionView.layoutIfNeeded()
        updateCollectionViewHeight()
    }
    
    private func setUpBindings(){
        viewModel.$isDataChanged
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reloadCollectionView() // Call your reload function here
            }
            .store(in: &cancellables)
        
        viewModel.$isDataChanged
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.configureUI() // Call your reload function here
            }
            .store(in: &cancellables)
        
        viewModel.$categories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] categories in
                self?.reloadCollectionView()
                self?.updateCollectionViewHeight() // Call your reload function here
            }
            .store(in: &cancellables)
        
    }
    
    private func configureUI() {
        amountTextField.text = viewModel.amount
        descriptionTextField.text = viewModel.info
        
        if viewModel.isFromExpenses == nil {
            configureCalendarButton()
        }
        
        
        
        print("ViewModel categories count: \(viewModel.categories.count)")
        
        // Find the selected category in viewModel.categories
        if let category = viewModel.category {
            print("Selected category title: \(category.title)")
            
            if let index = viewModel.categories.firstIndex(where: { $0.title == category.title }) {
                print("Found category at index: \(index)")
                
                // Select the category in the collection view
                let indexPath = IndexPath(item: index, section: 0)
                categoryCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
                
                // Update the cell's appearance to indicate selection
                if let cell = categoryCollectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell {
                    cell.contentView.backgroundColor = category.color
                } else {
                    print("Cell at indexPath \(indexPath) is nil")
                }
            } else {
                print("Category not found in viewModel.categories")
            }
        } else {
            print("viewModel.category is nil")
        }
    }
    
    private func configureCalendarButton(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM"
        
        // Convert the selectedDate to a string
        let dateString = dateFormatter.string(from: viewModel.date)
        
        // Set the formatted date string as the title of the calendarButton
        calendarButton.setTitle(dateString, for: .normal)
        calendarButton.isSelected = true
        calendarButton.backgroundColor = .lightGray
    }
    
    func reloadCollectionView() {
        // Perform collection view reload logic here
        if viewModel.isDataChanged {
            self.categoryCollectionView.reloadData()
            viewModel.isDataChanged = false
        }
    }
    
    
    private func setupViews() {
        
       
        
        amountTextField.delegate = self
        descriptionTextField.delegate = self
        
        setupScrollView()
        setupCollectionView()
        
        contentView.addSubview(amountTextField)
        contentView.addSubview(descriptionTextField)
        contentView.addSubview(currencyButton)
        contentView.addSubview(categoryCollectionView)
        contentView.addSubview(todayButton)
        contentView.addSubview(twoDaysAgoButton)
        contentView.addSubview(yesterdayButton)
        contentView.addSubview(calendarButton)
        contentView.addSubview(addButton)
        contentView.addSubview(calendarView)
        
        setupDropDownButton()
        setupDateButtonStyles()
        setupConstraints()
        setUpDatePicker()
        updateCollectionViewHeight()
    }
    
    
    
    @objc private func addButtonTapped() {
        viewModel.addTransaction().sink { completion in
            switch completion{
            case .failure(let error):
                print("Failed to save transaction: \(error.localizedDescription)")
            case .finished:
                print("Transaction saved successfully")
                self.navigationController?.popViewController(animated: true)
            }
        } receiveValue: {}
            .store(in: &cancellables)
        
        
    }
    
    @objc private func navigateCurrencyRateVC() {
        
        navigationController?.pushViewController(CurrencyScreenViewController(), animated: true)
    }
    
    @objc private func editButtonTapped() {
        viewModel.updateTransaction()
        navigationController?.backTwo()}
    
    
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.collectionView?.translatesAutoresizingMaskIntoConstraints = false
        
        categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        categoryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        categoryCollectionView.backgroundColor = .systemBackground
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        categoryCollectionView.isScrollEnabled = true
        
        categoryCollectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier)
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            amountTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            amountTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            amountTextField.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 3/7),
            amountTextField.heightAnchor.constraint(equalToConstant: 40),
            
            currencyButton.centerYAnchor.constraint(equalTo: amountTextField.centerYAnchor),
            currencyButton.leadingAnchor.constraint(equalTo: amountTextField.trailingAnchor, constant: 8),
            currencyButton.heightAnchor.constraint(equalTo: amountTextField.heightAnchor),
            currencyButton.widthAnchor.constraint(equalToConstant: 50),
            
            categoryCollectionView.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 16),
            categoryCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            categoryCollectionView.heightAnchor.constraint(equalTo: contentView.widthAnchor),
            
            todayButton.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor, constant: 8),
            todayButton.widthAnchor.constraint(equalToConstant: 80),
            todayButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            todayButton.heightAnchor.constraint(equalToConstant: 40),
            
            yesterdayButton.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor, constant: 8),
            yesterdayButton.widthAnchor.constraint(equalToConstant: 80),
            yesterdayButton.leadingAnchor.constraint(equalTo: todayButton.trailingAnchor, constant: 8),
            yesterdayButton.heightAnchor.constraint(equalTo: todayButton.heightAnchor),
            
            twoDaysAgoButton.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor, constant: 8),
            twoDaysAgoButton.leadingAnchor.constraint(equalTo: yesterdayButton.trailingAnchor, constant: 8),
            twoDaysAgoButton.widthAnchor.constraint(equalToConstant: 80),
            twoDaysAgoButton.heightAnchor.constraint(equalTo: todayButton.heightAnchor),
            
            calendarButton.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor, constant: 8),
            calendarButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            calendarButton.widthAnchor.constraint(equalToConstant: 80),
            calendarButton.heightAnchor.constraint(equalTo: todayButton.heightAnchor),
            
            descriptionTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 8),
            descriptionTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -8),
            descriptionTextField.heightAnchor.constraint(equalToConstant: 40),
            descriptionTextField.topAnchor.constraint(equalTo: todayButton.bottomAnchor, constant: 16),
            
            
            calendarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            calendarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            calendarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            calendarView.heightAnchor.constraint(equalToConstant: 300),
            calendarView.bottomAnchor.constraint(equalTo: calendarButton.topAnchor, constant: -16),
            
            addButton.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor,constant: 32),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -8),
            addButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 8),
            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            
            
        ])
        
        // Setting content hugging priority to make buttons resize based on their content
        [todayButton, twoDaysAgoButton, yesterdayButton, calendarButton].forEach { button in
            button.setContentHuggingPriority(.required, for: .horizontal)
            button.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
    }
}




