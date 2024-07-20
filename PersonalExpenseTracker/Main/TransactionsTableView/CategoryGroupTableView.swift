import UIKit

class CategoryGroupTableView: UIView, UITableViewDataSource, UITableViewDelegate{
    // MARK: - Properties
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var donutChartData: [(percentage: Double,color:UIColor)] = []
    private var categoryGroups: [CategoryGroup] = []
    
    weak var delegate: CategoryGroupTableViewDelegate?

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DoughnutChartCell.self, forCellReuseIdentifier: DoughnutChartCell.reuseIdentifier)
        tableView.register(CategoryGroupTableViewCell.self, forCellReuseIdentifier: CategoryGroupTableViewCell.reuseIdentifier)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Public Methods
    func setupData(donutChartData: [( percentage: Double,color: UIColor)], categoryGroups: [CategoryGroup]) {
        self.donutChartData = donutChartData
        self.categoryGroups = categoryGroups
        if categoryGroups.isEmpty {
            self.donutChartData = []
           }
        tableView.reloadData()
    }
    
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          if section == 0 {
              return donutChartData.isEmpty ? 0 : 1 // Display donut chart only if data is available
          } else {
              return categoryGroups.isEmpty ? 0 : categoryGroups.count
          }
      }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: DoughnutChartCell.reuseIdentifier, for: indexPath) as! DoughnutChartCell
            cell.configure(with: donutChartData)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CategoryGroupTableViewCell.reuseIdentifier, for: indexPath) as! CategoryGroupTableViewCell
            cell.configure(with: categoryGroups[indexPath.item])
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 240 : 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           guard indexPath.section == 1 else { return }
           let selectedCategoryGroup = categoryGroups[indexPath.row]
           delegate?.didSelectTransaction(selectedCategoryGroup)
       }
}

protocol CategoryGroupTableViewDelegate: AnyObject {
    func didSelectTransaction(_ categoryGroup: CategoryGroup)
}

