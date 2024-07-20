//
//  CategoryGroup.swift
//  PersonalExpenseTracker
//
//  Created by Sarvar on 10/07/24.
//

import Foundation
import UIKit

struct CategoryGroup{
    let category: Category
    let totalAmount: Double
    let percentage: Double
}

typealias ColorPercentageTuple = (percentage: Double,color: UIColor)
