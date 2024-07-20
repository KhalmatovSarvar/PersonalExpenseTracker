import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "CategoryCollectionViewCell"
    
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
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            updateSelectionState()
        }
    }
    
    var categoryColor: UIColor?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundCircleView.layer.cornerRadius = contentView.frame.width/2
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        contentView.addSubview(backgroundCircleView)
        backgroundCircleView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        
        
        
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with category: Category) {
        backgroundCircleView.backgroundColor = category.color
        iconImageView.image = category.icon.image
        titleLabel.text = category.title
        updateSelectionState()
    }
    
    func configureForAddCategory() {
        backgroundCircleView.backgroundColor = .white
        iconImageView.image = UIImage(systemName: "plus") // Assuming SF Symbols is used
        titleLabel.text = "Add Category"
        titleLabel.textColor = .systemBackground
        contentView.backgroundColor = .clear
    }
    
    private func updateSelectionState() {
        if isSelected {
            contentView.backgroundColor = categoryColor
        } else {
            contentView.backgroundColor = .clear
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundCircleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            backgroundCircleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundCircleView.heightAnchor.constraint(equalTo: contentView.widthAnchor),
            backgroundCircleView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            
            
            
            iconImageView.centerXAnchor.constraint(equalTo: backgroundCircleView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: backgroundCircleView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalTo: backgroundCircleView.widthAnchor, multiplier: 0.7), // Adjust size
            iconImageView.heightAnchor.constraint(equalTo: backgroundCircleView.heightAnchor,multiplier: 0.7), // Maintain aspect ratio
            
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleLabel.topAnchor.constraint(equalTo: backgroundCircleView.bottomAnchor),
            
        ])
    }
}
