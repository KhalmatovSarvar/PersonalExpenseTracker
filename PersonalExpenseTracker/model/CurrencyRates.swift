import Foundation

struct CurrencyRates: Codable {
    let date: String
    let base: String
    let rates: [String: String]
}
