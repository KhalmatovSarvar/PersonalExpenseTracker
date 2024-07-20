import UIKit

class DoughnutChartCell: UITableViewCell {
    static let reuseIdentifier = "DoughnutChartCell"

    // MARK: - Properties
    private let donutChart: DoughnutChartCircular = {
        let chart = DoughnutChartCircular(data: [], lineWidth: 10.0) // Initial empty data
        chart.translatesAutoresizingMaskIntoConstraints = false
        return chart
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        contentView.addSubview(donutChart)
        
        NSLayoutConstraint.activate([
            donutChart.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            donutChart.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            donutChart.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            donutChart.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            donutChart.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    // MARK: - Public Methods
    func configure(with data: [(percentage: Double, color: UIColor)]) {
        donutChart.updateData(data)
    }
}
