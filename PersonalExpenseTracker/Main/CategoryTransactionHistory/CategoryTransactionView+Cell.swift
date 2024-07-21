import UIKit

class CategoryTransactionViewCell: UITableViewCell {
    static let reuseIdentifier = "CategoryTransactionViewCell"
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
        addSubview(budgetLabel)
        
        NSLayoutConstraint.activate([
            backgroundCircleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            backgroundCircleView.centerYAnchor.constraint(equalTo: centerYAnchor),
            backgroundCircleView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            backgroundCircleView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
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
            
    
        ])
    }
    
    
    // MARK: - Configuration
    func configure(with item: Transaction) {
        backgroundCircleView.backgroundColor = item.category.color
        iconImageView.image = item.category.icon.image
        categoryNameLabel.text = item.category.title
        budgetLabel.text = "$\(item.amount)"
    }
}
