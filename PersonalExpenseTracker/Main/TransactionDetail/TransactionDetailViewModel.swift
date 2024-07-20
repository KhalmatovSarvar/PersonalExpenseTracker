//
//  TransactionDetailViewModel.swift
//  PersonalExpenseTracker
//
//  Created by Sarvar on 15/07/24.
//

import Foundation
import Combine

class TransactionDetailViewModel {
    private let coreDataManager = CoreDataManager.shared
   
    
     let transaction: Transaction
     
     init(transaction: Transaction) {
         self.transaction = transaction
     }
    
    func deleteTransaction() -> AnyPublisher<Void, Error> {
        return coreDataManager.deleteTransactionCoreData(with: transaction.id)
       }
    
    
}
