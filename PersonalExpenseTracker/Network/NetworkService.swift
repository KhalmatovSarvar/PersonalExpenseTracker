import Foundation
import Combine

class NetworkService {
    private let apiKey: String = "3bc0379a259f4d72ae1ac606b29cd1d0"
    private let urlString: String = "https://api.currencyfreaks.com/v2.0/rates/latest?apikey=3bc0379a259f4d72ae1ac606b29cd1d0&symbols=USD,EUR,JPY,GBP,AUD,CAD,CHF,CNY,HKD,NZD,SEK,KRW,SGD,NOK,INR,UZS"

    func fetchData() -> AnyPublisher<Data, Error> {
        guard let url = URL(string: urlString) else {
            return Fail(error: NSError(domain: "Invalid URL", code: 0, userInfo: nil))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { result in
                guard let httpResponse = result.response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return result.data
            }
            .eraseToAnyPublisher()
    }
}
