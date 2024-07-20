import Foundation
import Combine

class HomeViewModel {
    @Published var errorMessage: String?
    @Published var isLoading = false
    private var cancellables = Set<AnyCancellable>()
    
    let fireStoreManager = FirestoreManager.shared
    let dataRepo = DataRepository()
    
    
    init() {
//        if dataRepo.checkCategoryIsEmpty() { fetchCategoriesAndSave() }
//        if dataRepo.checkTransactionIsEmpty() {fetchTransactionsAndSave()}
        if dataRepo.checkCategoryIsEmpty() {
                  fetchCategoriesAndSave()
              } else {
                  setupCategoryListener()
              }
              
              if dataRepo.checkTransactionIsEmpty() {
                  fetchTransactionsAndSave()
              } else {
                  setupTransactionListener()
              }
       }

    private func setupTransactionListener(){
        isLoading = true
        dataRepo.synchronizeTransactionsFromFirestore()
            .sink(receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                self.isLoading = false
                                print("Failed to synchronize transactions: \(error)")
                            }
                        }, receiveValue: { _ in
                            
                            self.isLoading = false
                            print("Transactions synchronized successfully")
                        })
                        .store(in: &cancellables)
       }
    
    private func setupCategoryListener(){
        isLoading = true
        dataRepo.synchronizeCategoriesFromFirestore()
            .sink(receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                self.isLoading = false
                                print("Failed to synchronize transactions: \(error)")
                            }
                        }, receiveValue: { _ in
                            self.isLoading = false
                            print("Transactions synchronized successfully")
                        })
                        .store(in: &cancellables)
    }
    
    private func fetchTransactionsAndSave(){
        isLoading = true
        dataRepo.fetchTransactionsFromFireStoreOnceAndSyncThenSaveToDB()
            .sink(receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                self.isLoading = false
                                print("Failed to synchronize transactions: \(error)")
                            }
                        }, receiveValue: { _ in
                            self.isLoading = false
                            print("Transactions synchronized successfully")
                            self.setupTransactionListener()
                        })
                        .store(in: &cancellables)
    }
    
    private func fetchCategoriesAndSave(){
        isLoading = true
        dataRepo.fetchCategoriesFromFireStoreOnceAndSyncThenSaveToDB()
            .sink(receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                self.isLoading = false
                                print("Failed to synchronize transactions: \(error)")
                            }
                        }, receiveValue: { _ in
                            self.isLoading = false
                            print("Transactions synchronized successfully")
                            self.setupCategoryListener()
                        })
                        .store(in: &cancellables)
    }
}