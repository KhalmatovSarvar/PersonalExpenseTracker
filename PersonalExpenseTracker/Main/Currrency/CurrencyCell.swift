import UIKit

class CurrencyCell: UITableViewCell {
    private let flagImageView = UIImageView()
    private let currencyLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        flagImageView.translatesAutoresizingMaskIntoConstraints = false
        currencyLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .systemBackground
        
        contentView.addSubview(flagImageView)
        contentView.addSubview(currencyLabel)
        
        NSLayoutConstraint.activate([
            flagImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            flagImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            flagImageView.widthAnchor.constraint(equalToConstant: 30),
            flagImageView.heightAnchor.constraint(equalToConstant: 20),
            
            currencyLabel.leadingAnchor.constraint(equalTo: flagImageView.trailingAnchor, constant: 16),
            currencyLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            currencyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        currencyLabel.font = UIFont.systemFont(ofSize: 16)
       
    }
    
    func configure(with currencyCode: String, rate: String, flagURL: URL?) {
        currencyLabel.text = " \(rate) \(currencyCode)"
        currencyLabel.textColor = .appText
        
        // Load the image asynchronously
        if let url = flagURL {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.flagImageView.image = image
                    }
                } else {
                    DispatchQueue.main.async {
                        self.flagImageView.image = nil
                    }
                }
            }
        } else {
            flagImageView.image = nil
        }
    }
}
