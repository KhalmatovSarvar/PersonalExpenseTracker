import UIKit
import Combine

class CurrencyScreenViewController: UIViewController, UITableViewDataSource {
    private var viewModel = CurrencyViewModel()
    private var tableView: UITableView!
    private var cancellables: Set<AnyCancellable> = []
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .blue
        return activityIndicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Currencies"
        setupTableView()
        bindViewModel()
        viewModel.fetchCurrencyRates()
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.dataSource = self
        tableView.register(CurrencyCell.self, forCellReuseIdentifier: "CurrencyCell")
        view.addSubview(tableView)
    }
    
    private func bindViewModel() {
        viewModel.$currencyRates
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                 isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
            }
            .store(in: &cancellables)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.currencyRates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath) as! CurrencyCell
        let currencyCode = Array(viewModel.currencyRates.keys)[indexPath.row]
        let currencyRate = viewModel.currencyRates[currencyCode] ?? ""
        
        // Map currency codes to flag URLs
        
            let flagURLs: [String: String] = [
                "USD": "https://flagcdn.com/32x24/us.png",
                "EUR": "https://flagcdn.com/32x24/eu.png",
                "JPY": "https://flagcdn.com/32x24/jp.png",
                "GBP": "https://flagcdn.com/32x24/gb.png",
                "AUD": "https://flagcdn.com/32x24/au.png",
                "CAD": "https://flagcdn.com/32x24/ca.png",
                "CHF": "https://flagcdn.com/32x24/ch.png",
                "CNY": "https://flagcdn.com/32x24/cn.png",
                "HKD": "https://flagcdn.com/32x24/hk.png",
                "NZD": "https://flagcdn.com/32x24/nz.png",
                "SEK": "https://flagcdn.com/32x24/se.png",
                "KRW": "https://flagcdn.com/32x24/kr.png",
                "SGD": "https://flagcdn.com/32x24/sg.png",
                "NOK": "https://flagcdn.com/32x24/no.png",
                "INR": "https://flagcdn.com/32x24/in.png",
                "UZS": "https://flagcdn.com/32x24/uz.png"
            ]

        
        
        let flagURLString = flagURLs[currencyCode]
        let flagURL = flagURLString.flatMap { URL(string: $0) }
        
        cell.configure(with: currencyCode, rate: currencyRate, flagURL: flagURL)
        return cell
    }
}
