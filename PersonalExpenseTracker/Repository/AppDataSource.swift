import Combine
import UIKit
import CoreData

class AppDataSource: ObservableObject {
    
    static let shared = AppDataSource()

    let initialCategories: [Category] = [
            Category(title: "Food", color: .systemBlue, icon: ImageWrapper(image: UIImage(systemName: "circle.square")!)),
            Category(title: "Shopping", color: .systemGreen, icon: ImageWrapper(image: UIImage(systemName: "figure.walk")!)),
            Category(title: "Transport", color: .systemOrange, icon: ImageWrapper(image: UIImage(systemName: "location.fill")!)),
            Category(title: "Entertainment", color: .systemPurple, icon: ImageWrapper(image: UIImage(systemName: "house.fill")!)),
            Category(title: "Health", color: .systemRed, icon: ImageWrapper(image: UIImage(systemName: "fan.fill")!)),
            Category(title: "Utilities", color: .systemYellow, icon: ImageWrapper(image: UIImage(systemName: "location.fill")!))
    ]
    
}
