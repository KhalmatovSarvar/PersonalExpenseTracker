import UIKit

class CategoryGroupTableViewCell: UITableViewCell {
    static let reuseIdentifier = "TransactionTableViewCell"
    // MARK: - Properties
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let backgroundCircleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        return view
    }()
    
    
    private let categoryNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let percentageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        return label
    }()
    
    private let budgetLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        return label
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Setup
    private func setupViews() {
        addSubview(backgroundCircleView)
        backgroundCircleView.addSubview(iconImageView)
        addSubview(categoryNameLabel)
        addSubview(percentageLabel)
        addSubview(budgetLabel)
        
        NSLayoutConstraint.activate([
            backgroundCircleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            backgroundCircleView.centerYAnchor.constraint(equalTo: centerYAnchor),
            backgroundCircleView.widthAnchor.constraint(equalToConstant: 40),
            backgroundCircleView.heightAnchor.constraint(equalToConstant: 40),
            // Making it circular
            
            iconImageView.centerXAnchor.constraint(equalTo: backgroundCircleView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: backgroundCircleView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 30), // Smaller icon
            iconImageView.heightAnchor.constraint(equalToConstant: 30),
            
            categoryNameLabel.leadingAnchor.constraint(equalTo: backgroundCircleView.trailingAnchor, constant: 16),
            categoryNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            budgetLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            budgetLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            percentageLabel.trailingAnchor.constraint(equalTo: budgetLabel.leadingAnchor, constant: -20),
            percentageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            percentageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: categoryNameLabel.trailingAnchor, constant: 8) // Ensure
        ])
    }
    
    
    // MARK: - Configuration
    func configure(with item: CategoryGroup) {
        backgroundCircleView.backgroundColor = item.category.color
        iconImageView.image = item.category.icon.image
        categoryNameLabel.text = item.category.title
        percentageLabel.text = String(format: "%.2f", item.percentage)+"%"
        budgetLabel.text = "$\(item.totalAmount)"
    }
}
