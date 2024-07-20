import UIKit
import Combine

class SignUpViewController: UIViewController {
    
    // MARK: - Properties
    var viewModel = SignUpViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: - Outlets
    let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .blue
        return activityIndicator
    }()
    
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Name"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        textField.textColor = .appText
        textField.autocorrectionType = .no
        return textField
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        textField.textColor = .appText
        textField.autocorrectionType = .no
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        textField.textColor = .appText
        textField.autocorrectionType = .no
        return textField
    }()
    
    let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Confirm Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        textField.textColor = .appText
        textField.autocorrectionType = .no
        return textField
    }()
    
    let ageTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Age"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        textField.textColor = .appText
        textField.autocorrectionType = .no
        return textField
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    let signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        self.navigationItem.title = "Sign Up"
        
        setupUI()
        addTapGesture()
        bindViewModel()
        
        // Assign delegates
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        ageTextField.delegate = self
        
        
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        
        
    }
    
    
    // MARK: - UI Setup
    private func setupUI() {
        // Add subviews
        view.addSubview(nameTextField)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(confirmPasswordTextField)
        view.addSubview(ageTextField)
        view.addSubview(signUpButton)
        view.addSubview(activityIndicator)
        view.addSubview(signInButton)
        
        // Disable autoresizing mask constraints
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        ageTextField.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        
        
        // Setup constraints
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            ageTextField.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 20),
            ageTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            ageTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signUpButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
            
            signInButton.topAnchor.constraint(equalTo: ageTextField.bottomAnchor,constant: 8),
            signInButton.trailingAnchor.constraint(equalTo: ageTextField.trailingAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            
        ])
    }
    
    //MARK: - binding values from Viewmodel
    private func bindViewModel() {
        viewModel.$isLoading
            .sink { [weak self] isLoading in
                isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
                self?.signUpButton.isEnabled = !isLoading
            }
            .store(in: &cancellables)
        
        viewModel.$signUpSuccess
            .removeDuplicates()
            .sink { [weak self] success in
                if success {
//                    self?.showAlert(message: "Sign up successful", isError: false)
                    self?.saveCredentials()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    // Display error message to the user
                    self?.showAlert(message: errorMessage)
                }
            }
            .store(in: &cancellables)
    }
    
    @objc private func signUpButtonTapped(){
        if viewModel.isValid().result {
            viewModel.signUp()
        }else{
            let errorMessage = viewModel.isValid().errorMessage
            showAlert(message: errorMessage)
        }
    }
    
    @objc private func signInButtonTapped(){
        navigationController?.pushViewController(SignInViewController(), animated: true)
    }
    
    //function that hides the keyboard
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
        
    }
    

    
    private func saveCredentials(){
        viewModel.saveCredentials { [weak self] result in
            switch result {
              case .success:
                  print("Credentials saved successfully.")
                  self?.navigationController?.pushViewController(SignInViewController(), animated: true)
                  // Handle success scenario
                  
              case .failure(let error):
                  // Handle failure scenario
                  print("Failed to save credentials. Error: \(error.localizedDescription)")
                  // Optionally update UI or show error message to the user
              }
        }
    }
    
}

// MARK: - UITextFieldDelegate
extension SignUpViewController: UITextFieldDelegate {
    
    //triggers corresponding value to viewmodel
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == nameTextField {
            let newName = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
            viewModel.name = newName
        } else if textField == emailTextField {
            let newEmail = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
            viewModel.email = newEmail
        } else if textField == passwordTextField {
            let newPassword = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
            viewModel.password = newPassword
        } else if textField == confirmPasswordTextField {
            let newConfirmPassword = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
            viewModel.confirmPassword = newConfirmPassword
        } else if textField == ageTextField {
            let newAgeString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
            viewModel.age = Int(newAgeString) ?? 0
        }
        
        return true
    }
    
    
    // function that moves cursor to next textfield if return pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        case confirmPasswordTextField:
            ageTextField.becomeFirstResponder()
        case ageTextField:
            ageTextField.resignFirstResponder()
            dismissKeyboard() // Call dismissKeyboard to ensure keyboard is hidden
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
}

