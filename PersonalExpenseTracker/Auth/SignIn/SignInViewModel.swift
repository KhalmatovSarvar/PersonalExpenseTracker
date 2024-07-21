//
//  SignInViewModel.swift
//  PersonalExpenseTracker
//
//  Created by Sarvar on 02/07/24.
//

import Foundation
import Combine

class SignInViewModel {
    
    // MARK: - Properties
    @Published var isLoading: Bool = false
    @Published var signInSuccess: Bool = false
    @Published var errorMessage: String?
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    var validateInputError: ValidationError? = nil
    
    var isValidEmail: Bool = false
    var isValidPassword: Bool = false
    
    // Other properties and Combine cancellables
    private var cancellables = Set<AnyCancellable>()
    private let authService: AuthService
    
    // Initializer
    init(authService: AuthService = AuthService.shared) {
        self.authService = authService
        self.setupValidation()
    }
    
    deinit {
        //disable observables
        cancellables.forEach { $0.cancel() }
    }
    
    private func setupValidation() {
        $email
            .sink { [weak self] email in
                self?.isValidEmail = email.isValidEmail
            }
            .store(in: &cancellables)
        
        $password
            .sink { [weak self] password in
                self?.isValidPassword = (password.count >= 6)
            }
            .store(in: &cancellables)
    }
    
    func isValid() -> (errorMessage: String, result: Bool) {
        var errorMessages: [String] = []
    
        if !isValidEmail {
            errorMessages.append(ValidationError.invalidEmail.description)
        }
        if !isValidPassword {
            errorMessages.append(ValidationError.invalidPassword.description)
        }
        
        let allValid = errorMessages.isEmpty
        let errorMessage = errorMessages.joined(separator: "\n")
        
        return (errorMessage, allValid)
    }
    
    func signIn(){
        isLoading = true
        
        authService.login(email: self.email, password: self.password) { [weak self] result in
            self?.isLoading = false
            
            switch result{
            case .success(_):
                self?.signInSuccess = true
                self?.errorMessage = nil
                self?.saveInfo()
            case .failure(let error):
                self?.signInSuccess = false
                self?.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func saveInfo(){
        MyUserDefaults.shared.isUserSignedIn = true
        MyUserDefaults.shared.userEmail = email
    }
    
    func checkEmailInKeychain() {
        print("beginVM: \(password)")
        isLoading = true
        if let savedPassword = KeychainService.shared.getPassword(for: email) {
            password = savedPassword
        } else {
            password = "" // Clear the password field if no password is found
        }
        isLoading = false
        print("finishVM: \(password)")
    }
    
    
}
