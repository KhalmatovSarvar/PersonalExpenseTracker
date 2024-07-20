//
//  TransactionDetailViewController.swift
//  PersonalExpenseTracker
//
//  Created by Sarvar on 09/07/24.
//

import UIKit
import Combine

class TransactionDetailViewController:UIViewController{

    private var cancellables = Set<AnyCancellable>()
  
    private let viewModel: TransactionDetailViewModel
       
       // Initialize the view controller with a Transaction
       init(transaction: Transaction) {
           self.viewModel = TransactionDetailViewModel(transaction: transaction)
           super.init(nibName: nil, bundle: nil)
       }
       
       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }

    
    // MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let categoryNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoryColorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let editButton: UIButton = {
        let button = UIButton()
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("Delete", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupView()
        setUpActions()
        configureUI()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.addSubview(titleLabel)
        view.addSubview(amountLabel)
        view.addSubview(categoryImageView)
        view.addSubview(categoryNameLabel)
        view.addSubview(categoryColorView)
        view.addSubview(dateLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(editButton)
        view.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            amountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            amountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            categoryImageView.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 16),
            categoryImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryImageView.widthAnchor.constraint(equalToConstant: 30),
            categoryImageView.heightAnchor.constraint(equalToConstant: 30),
            
            categoryNameLabel.centerYAnchor.constraint(equalTo: categoryImageView.centerYAnchor),
            categoryNameLabel.leadingAnchor.constraint(equalTo: categoryImageView.trailingAnchor, constant: 8),
            
            categoryColorView.centerYAnchor.constraint(equalTo: categoryImageView.centerYAnchor),
            categoryColorView.leadingAnchor.constraint(equalTo: categoryNameLabel.trailingAnchor, constant: 8),
            categoryColorView.widthAnchor.constraint(equalToConstant: 20),
            categoryColorView.heightAnchor.constraint(equalToConstant: 20),
            
            dateLabel.topAnchor.constraint(equalTo: categoryImageView.bottomAnchor, constant: 16),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            descriptionLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            editButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            editButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            deleteButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Configure Method
    private func configureUI() {
        titleLabel.text = "Transaction Details"
        amountLabel.text = "Amount: \(viewModel.transaction.amount)"
        categoryImageView.image = viewModel.transaction.category.icon.image
        categoryNameLabel.text = viewModel.transaction.category.title
        categoryColorView.backgroundColor = viewModel.transaction.category.color
        dateLabel.text = "Date: \(viewModel.transaction.date)"
        descriptionLabel.text = viewModel.transaction.info
    }
    
    private func setUpActions(){
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    
    @objc private func editButtonTapped() {
        let vc = AddTransactionViewController(
            isFromExpenses: nil,
            transaction: viewModel.transaction
        )
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc func deleteButtonTapped() {
            viewModel.deleteTransaction()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Transaction deleted successfully")
                        self.navigationController?.popViewController(animated: true)
                    case .failure(let error):
                        print("Failed to delete transaction: \(error.localizedDescription)")
                        // Handle error (e.g., show error message)
                    }
                }, receiveValue: {
                    // Optional: Handle success value if needed
                })
                .store(in: &cancellables)
        }
}

