//
//  SignUpViewModel.swift
//  PersonalExpenseTracker
//
//  Created by Sarvar on 30/06/24.
//

import Foundation
import Combine
import FirebaseAuth

class SignUpViewModel {
    
    // MARK: - Properties
    @Published var isLoading: Bool = false
    @Published var signUpSuccess: Bool = false
    @Published var errorMessage: String?
    
    
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var age: Int = 0
    
    var validateInputError: ValidationError? = nil
    
    var isValidName: Bool = false
    var isValidEmail: Bool = false
    var isValidPassword: Bool = false
    var isValidConfirm: Bool = false
    var isValidAge: Bool = false
    
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
        $name
            .sink { [weak self] name in
                self?.isValidName = (name.count > 3)
            }
            .store(in: &cancellables)
        
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
        
        Publishers.CombineLatest($password, $confirmPassword)
            .sink { [weak self] password, confirmPassword in
                self?.isValidConfirm = (password == confirmPassword && password.count >= 6)
            }
            .store(in: &cancellables)
        
        $age
            .sink { [weak self] age in
                self?.isValidAge = (age > 0)
            }
            .store(in: &cancellables)
        
    }
    
    func isValid() -> (errorMessage: String, result: Bool) {
        var errorMessages: [String] = []
        
        if !isValidName {
            errorMessages.append(ValidationError.invalidName.description)
        }
        if !isValidEmail {
            errorMessages.append(ValidationError.invalidEmail.description)
        }
        if !isValidPassword {
            errorMessages.append(ValidationError.invalidPassword.description)
        }
        if !isValidConfirm {
            errorMessages.append(ValidationError.passwordMismatch.description)
        }
        if !isValidAge {
            errorMessages.append(ValidationError.invalidAge.description)
        }
        
        let allValid = errorMessages.isEmpty
        let errorMessage = errorMessages.joined(separator: "\n")
        
        return (errorMessage, allValid)
    }
    
    // Sign-Up Method
    func signUp() {
        isLoading = true
        
        authService.signUp(name: self.name, age: self.age,email: self.email, password: self.password) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success:
                self?.signUpSuccess = true
                self?.errorMessage = nil
                self?.saveInfo()
            case .failure(let error):
                self?.signUpSuccess = false
                self?.errorMessage = error.localizedDescription
            }
        }
    }
    
    //save credentials
     func saveCredentials(completion: @escaping (Result<Void, Error>) -> Void) {
        // Set isLoading to true to indicate loading state
        isLoading = true
        
        DispatchQueue.global(qos: .background).async {
            let credentials = Credentials(email: self.email, password: self.password)
            
            KeychainService.shared.addQuery(credentials: credentials)
            
            DispatchQueue.main.async {
                // Return success to indicate the operation completed (assuming no explicit error handling in KeychainService)
                self.isLoading = false // Set isLoading back to false after operation completes
                self.errorMessage = nil // Clear any previous error message
                
                completion(.success(()))
            }
        }
    }
    
    
    private func saveInfo(){
        MyUserDefaults.shared.isUserSignedUp = true
        MyUserDefaults.shared.userAge = age
        MyUserDefaults.shared.userName = name
        MyUserDefaults.shared.userEmail = email
    }
    
}

// MARK: - Extensions

extension String {
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
}

//MARK: - Error enums
enum ValidationError: Error {
    case invalidName
    case invalidEmail
    case invalidPassword
    case passwordMismatch
    case invalidAge
    
    var description: String{
        switch self{
        case .invalidAge: return "Age must be greater than zero"
        case .invalidEmail: return "Invalid email"
        case .invalidPassword: return "Password must be at least 6 characters"
        case .invalidName: return "Name length must be at least 3 characters"
        case .passwordMismatch: return "Password did not match"
        }
    }
}

