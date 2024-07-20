import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ColorCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        contentView.clipsToBounds = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layer.borderWidth = 0.0
        contentView.layer.masksToBounds = true
    }
    
    func configure(with color: UIColor) {
        backgroundColor = color
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
       
    }
    
    override var isSelected: Bool {
        didSet {
            contentView.layer.borderWidth = isSelected ? 2.0 : 0.0
        }
    }
}
