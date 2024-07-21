import Foundation
import Combine

class CurrencyViewModel: ObservableObject {
    @Published var currencyRates: [String: String] = [:]
    @Published var isLoading = false
    private var cancellables: Set<AnyCancellable> = []
    private let networkService = NetworkService()
    
    func fetchCurrencyRates() {
        isLoading = true
        networkService.fetchData()
            .decode(type: CurrencyRates.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.isLoading = false
                    break
                case .failure(let error):
                    self.isLoading = false
                    print("Error fetching data: \(error)")
                }
            }, receiveValue: { [weak self] currencyRates in
                self?.currencyRates = currencyRates.rates
            })
            .store(in: &cancellables)
    }
}
