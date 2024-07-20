import UIKit

class IconCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "IconCell"
        
    
    override var isSelected: Bool {
           didSet {
               contentView.backgroundColor = isSelected ? UIColor.systemBlue.withAlphaComponent(0.5) : .clear
           }
       }
        private let image: UIImageView = {
            let image = UIImageView()
            image.translatesAutoresizingMaskIntoConstraints = false
            return image
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setup() {
            layer.cornerRadius = 10 // Rounded corners
            layer.borderWidth = 1.0
            layer.borderColor = UIColor.lightGray.cgColor
        
            backgroundColor = .systemGray6
            addSubview(image)
            NSLayoutConstraint.activate([
                image.centerXAnchor.constraint(equalTo: centerXAnchor),
                image.centerYAnchor.constraint(equalTo: centerYAnchor),
                image.widthAnchor.constraint(equalToConstant: 40),
                image.heightAnchor.constraint(equalToConstant: 40),
            ])
        }
        
        func configure(with icon: String) {
            image.image = UIImage(systemName: icon)
        }
    }

