import UIKit
import Combine

class SignInViewController: UIViewController {
    
    // MARK: - Properties
    var viewModel = SignInViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Outlets
    let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .blue
        return activityIndicator
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        textField.setPlaceHolderColor()
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
        textField.setPlaceHolderColor()
        textField.textColor = .appText
        textField.autocorrectionType = .no
        return textField
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.appText, for: .normal)
        return button
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.navigationItem.title = "Login"
        
        setupUI()
        addTapGesture()
        bindViewModel()
        
        // Assign delegates
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(goSignUp), for: .touchUpInside)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        navigationItem.hidesBackButton = true
        // Add subviews
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(activityIndicator)
        view.addSubview(signUpButton)
        
        // Disable autoresizing mask constraints
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup constraints
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            loginButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 15),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            
            signUpButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 8),
            signUpButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor, constant: -8),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Button Action
    @objc private func loginButtonTapped() {
        if viewModel.isValid().result{
            viewModel.signIn()
        }else{
            showAlert(message: viewModel.isValid().errorMessage)
        }
    }
    
    @objc private func goSignUp() {
        if navigationController?.viewControllers.count ?? 0 > 1 {
                // Pop to the root view controller or one step back in the stack
                navigationController?.popToRootViewController(animated: true)
            } else {
                // If no view controllers to pop, push to the sign-up view controller
                let signUpVC = SignUpViewController() // Replace with your actual sign-up view controller initialization
                navigationController?.setViewControllers([signUpVC], animated: true)
            }    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func bindViewModel() {
        // Binding code for viewModel to update UI can be added here
        
        viewModel.$isLoading
            .sink { [weak self] isLoading in
                isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
                self?.loginButton.isEnabled = !isLoading
            }
            .store(in: &cancellables)
        
        viewModel.$signInSuccess
            .removeDuplicates()
            .sink { [weak self] success in
                if success {
                    //                    self?.showAlert(message: "Sign up successful", isError: false)
                    //go to main page
                    let homeViewController = HomeViewController()
                       
                       // Use a navigation controller to replace the current stack
                       if let navigationController = self?.navigationController {
                           navigationController.setViewControllers([homeViewController], animated: true)
                       } else {
                           // If there's no navigation controller, present HomeViewController modally
                           self?.present(homeViewController, animated: true, completion: nil)
                       }
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
}


extension SignInViewController: UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTextField{
            viewModel.email = textField.text ?? ""
            viewModel.checkEmailInKeychain()
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == passwordTextField {
            let password = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
            viewModel.password = password
        }
        return true
    }
}
