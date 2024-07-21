import Foundation
import Combine

class NetworkManager {
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func fetchAndParseData() -> AnyPublisher<CurrencyRates, Error> {
        return networkService.fetchData()
            .decode(type: CurrencyRates.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
