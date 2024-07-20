//import UIKit
//import Combine
//
//class AddCategoryViewController: UIViewController {
//
//    var cancellables = Set<AnyCancellable>()
//    var viewModel = AddCategoryViewModel()
//
//    let scrollView: UIScrollView = {
//        let scrollView = UIScrollView()
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        return scrollView
//    }()
//
//    let contentView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    let categoryNameTextField: UITextField = {
//        let textField = UITextField()
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        textField.placeholder = "Category Name"
//        textField.borderStyle = .roundedRect
//        return textField
//    }()
//
//    let addButton: UIButton = {
//        let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setTitle("Add", for: .normal)
//        button.backgroundColor = .systemBlue
//        button.setTitleColor(.white, for: .normal)
//        button.layer.cornerRadius = 10
//        return button
//    }()
//
//    var iconCollectionView: UICollectionView!
//
//    let colorCollectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.backgroundColor = .clear
//        return collectionView
//    }()
//
//    let iconData: [String] = ["dollarsign.circle", "bag", "figure", "airplane.arrival", "car", "lightrail", "house", "bolt.badge.checkmark", "display.2", "airpodsmax", "mountain.2", "figure.bowling"]
//    let colorData: [UIColor] = [.red, .orange, .yellow, .green, .blue, .purple, .brown, .gray, .cyan, .magenta, .darkGray, .lightGray]
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        setupCollectionView()
//
//        view.backgroundColor = .systemBackground
//        view.addSubview(scrollView)
//        scrollView.addSubview(contentView)
//
//        contentView.addSubview(categoryNameTextField)
//        contentView.addSubview(iconCollectionView)
//        contentView.addSubview(colorCollectionView)
//        contentView.addSubview(addButton)
//
//        setUpActions()
//
//        setupConstraints()
//        updateCollectionViewHeight()
//
//    }
//
//    private func setUpBindings(){
//
//    }
//
//    private func setUpActions(){
//        categoryNameTextField.delegate = self
//        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
//    }
//
//    @objc private func addButtonTapped() {
//        viewModel.addCategory()
//                    .sink(receiveCompletion: { completion in
//                        switch completion {
//                        case .finished:
//                            print("Category saved successfully")
//                            self.navigationController?.popViewController(animated: false)
//                        case .failure(let error):
//                            print("Failed to save category: \(error.localizedDescription)")
//                            // Handle error
//                        }
//                    }, receiveValue: {
//                        // Optional: Handle success value if needed
//                    })
//                    .store(in: &cancellables)
//
//    }
//
//    private func setupCollectionView() {
//        let iconLayout = UICollectionViewFlowLayout()
//        iconLayout.itemSize = CGSize(width: 60, height: 60)
//        iconLayout.minimumInteritemSpacing = 10
//        iconLayout.minimumLineSpacing = 10
//        iconCollectionView = UICollectionView(frame: .zero, collectionViewLayout: iconLayout)
//        iconCollectionView.translatesAutoresizingMaskIntoConstraints = false
//        iconCollectionView.backgroundColor = .clear
//        iconCollectionView.dataSource = self
//        iconCollectionView.delegate = self
//        iconCollectionView.isScrollEnabled = false
//        iconCollectionView.register(IconCollectionViewCell.self, forCellWithReuseIdentifier: IconCollectionViewCell.reuseIdentifier)
//
//        let colorLayout = UICollectionViewFlowLayout()
//        colorLayout.scrollDirection = .horizontal
//        colorCollectionView.collectionViewLayout = colorLayout
//        colorCollectionView.dataSource = self
//        colorCollectionView.delegate = self
//        colorCollectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.reuseIdentifier)
//    }
//
//
//    private func updateCollectionViewHeight() {
//        let totalItems = iconData.count
//        let itemsPerRow: CGFloat = 4
//        let rows = ceil(CGFloat(totalItems) / itemsPerRow)
//        let itemHeight: CGFloat = 60
//        let spacing: CGFloat = 10
//
//        let totalHeight = (rows * itemHeight) + ((rows - 1) * spacing)
//        iconCollectionView.heightAnchor.constraint(equalToConstant: totalHeight).isActive = true
//    }
//
//
//    private func setupConstraints() {
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//
//            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
//
//            categoryNameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
//            categoryNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            categoryNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            categoryNameTextField.heightAnchor.constraint(equalToConstant: 40),
//
//            iconCollectionView.topAnchor.constraint(equalTo: categoryNameTextField.bottomAnchor, constant: 20),
//            iconCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            iconCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//
//            colorCollectionView.topAnchor.constraint(equalTo: iconCollectionView.bottomAnchor, constant: 20),
//            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            colorCollectionView.heightAnchor.constraint(equalToConstant: 60),
//
//            addButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 20),
//            addButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            addButton.widthAnchor.constraint(equalToConstant: 100),
//            addButton.heightAnchor.constraint(equalToConstant: 50),
//            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
//        ])
//    }
//
//}
//
//
//extension AddCategoryViewController : UITextFieldDelegate {
//
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if textField == categoryNameTextField {
//            let name = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
//            viewModel.categoryName = name
//        }
//    return true
//    }
//        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//            switch textField {
//            case categoryNameTextField :
//                categoryNameTextField.becomeFirstResponder()
//            default:
//                textField.resignFirstResponder()
//            }
//
//        }
//
//    }
//
//
//
import UIKit
import Combine

class AddCategoryViewController: UIViewController {
    
    var cancellables = Set<AnyCancellable>()
    var viewModel = AddCategoryViewModel()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let categoryNameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Category Name"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    let addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    var iconCollectionView: UICollectionView!
    
    let colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    let iconData: [String] = ["dollarsign.circle",
                              "bag",
                              "figure",
                              "airplane.arrival",
                              "car",
                              "lightrail",
                              "house",
                              "bolt.badge.checkmark",
                              "display.2",
                              "airpodsmax",
                              "mountain.2",
                              "figure.bowling",
                              "star",
                              "heart",
                              "calendar"]
    let colorData: [UIColor] = [.red, .orange, .yellow, .green, .blue, .purple, .brown, .gray, .cyan, .magenta, .darkGray, .lightGray]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(categoryNameTextField)
        contentView.addSubview(iconCollectionView)
        contentView.addSubview(colorCollectionView)
        contentView.addSubview(addButton)
        
        setUpActions()
        
        setupConstraints()
        updateCollectionViewHeight()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        iconCollectionView.collectionViewLayout.invalidateLayout()
    }

    
    private func setUpBindings() {
        // Bindings setup
    }
    
    private func setUpActions() {
        categoryNameTextField.delegate = self
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    @objc private func addButtonTapped() {
        viewModel.addCategory()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Category saved successfully")
                    self.navigationController?.popViewController(animated: false)
                case .failure(let error):
                    print("Failed to save category: \(error.localizedDescription)")
                    // Handle error
                }
            }, receiveValue: {
                // Optional: Handle success value if needed
            })
            .store(in: &cancellables)
    }
    
    private func setupCollectionView() {
        // Icon Collection View Layout
        let iconLayout = UICollectionViewFlowLayout()
        
        // Set item size dynamically to fit 4 items per row
        let itemsPerRow: CGFloat = 4
        let spacing: CGFloat = 10
        let totalSpacing = (itemsPerRow - 1) * spacing
        let availableWidth = view.bounds.width - (2 * 20) - totalSpacing // Account for leading and trailing padding
        
        let itemWidth = availableWidth / itemsPerRow
        iconLayout.itemSize = CGSize(width: itemWidth, height: itemWidth) // Square items
        iconLayout.minimumInteritemSpacing = spacing
        iconLayout.minimumLineSpacing = spacing
        
        iconCollectionView = UICollectionView(frame: .zero, collectionViewLayout: iconLayout)
        iconCollectionView.translatesAutoresizingMaskIntoConstraints = false
        iconCollectionView.backgroundColor = .clear
        iconCollectionView.dataSource = self
        iconCollectionView.delegate = self
        iconCollectionView.isScrollEnabled = false
        iconCollectionView.register(IconCollectionViewCell.self, forCellWithReuseIdentifier: IconCollectionViewCell.reuseIdentifier)
        
        // Color Collection View Layout
        let colorLayout = UICollectionViewFlowLayout()
        colorLayout.scrollDirection = .horizontal
        colorCollectionView.collectionViewLayout = colorLayout
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.reuseIdentifier)
    }
    
    private func updateCollectionViewHeight() {
        let totalItems = iconData.count
        let itemsPerRow: CGFloat = 4
        let rows = ceil(CGFloat(totalItems) / itemsPerRow)
        let itemHeight: CGFloat = 60
        let spacing: CGFloat = 10
        
        let totalHeight = (rows * itemHeight) + ((rows - 1) * spacing)
        iconCollectionView.heightAnchor.constraint(equalToConstant: totalHeight).isActive = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            categoryNameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            categoryNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            categoryNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            categoryNameTextField.heightAnchor.constraint(equalToConstant: 40),
            
            iconCollectionView.topAnchor.constraint(equalTo: categoryNameTextField.bottomAnchor, constant: 20),
            iconCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            iconCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            iconCollectionView.heightAnchor.constraint(equalTo: contentView.widthAnchor),
            
            colorCollectionView.topAnchor.constraint(equalTo: iconCollectionView.bottomAnchor, constant: 20),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 60),
            
            addButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 20),
            addButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 100),
            addButton.heightAnchor.constraint(equalToConstant: 50),
            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
}

extension AddCategoryViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == categoryNameTextField {
            let name = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
            viewModel.categoryName = name
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case categoryNameTextField:
            categoryNameTextField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}

