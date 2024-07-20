//
//  TransactionDetailViewModel.swift
//  PersonalExpenseTracker
//
//  Created by Sarvar on 15/07/24.
//

import Foundation
import Combine

class TransactionDetailViewModel {
    private let dataRepo = DataRepository()
   
    
     let transaction: Transaction
     
     init(transaction: Transaction) {
         self.transaction = transaction
     }
    
    func deleteTransaction() -> AnyPublisher<Void, Error> {
        return dataRepo.deleteTransaction(with: transaction.id)
       }
    
    
}
