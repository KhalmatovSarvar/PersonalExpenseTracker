//
//  AddTransactionViewController+Buttons.swift
//  PersonalExpenseTracker
//
//  Created by Sarvar on 08/07/24.
//

import UIKit

extension AddTransactionViewController{
    
    
    func setupDropDownButton() {
        currencyButton.translatesAutoresizingMaskIntoConstraints = false
        var menuChildren: [UIMenuElement] = []
        let dataSource = Currency.allCases.map { $0.description }
        
        // Ensure dataSource is not empty
        guard !dataSource.isEmpty else {
            return
        }
        
        // Create UIActions for each currency
        for currency in dataSource {
            let action = UIAction(title: currency) { [weak self] action in
                guard let self = self else { return }
                self.viewModel.currency = Currency(rawValue: action.title)!
                print("Selected currency: \(action.title)")
            }
            menuChildren.append(action)
        }
        
        // Check if menuChildren is not empty before assigning to UIMenu
        guard !menuChildren.isEmpty else {
            return
        }
        
        currencyButton.menu = UIMenu(options: .displayInline, children: menuChildren)
        currencyButton.showsMenuAsPrimaryAction = true
        currencyButton.changesSelectionAsPrimaryAction = true
    }

        
        func setupDateButtonStyles() {
            
            
            
            let today = Date()
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
            let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
            
            
            todayButton.setTitle("\(formatDate(today))\nToday", for: .normal)
            twoDaysAgoButton.setTitle("\(formatDate(twoDaysAgo))", for: .normal)
            yesterdayButton.setTitle("\(formatDate(yesterday))\nYesterday", for: .normal)
            calendarButton.setTitle("Calendar", for: .normal)
            
            [todayButton, twoDaysAgoButton, yesterdayButton, calendarButton].forEach { button in
                button.translatesAutoresizingMaskIntoConstraints = false
                button.setTitleColor(.systemBlue, for: .normal)
                button.backgroundColor = .lightGray.withAlphaComponent(0.3)
                button.layer.cornerRadius = 8
                button.backgroundColor = .clear
                button.titleLabel?.numberOfLines = 2
                button.titleLabel?.textAlignment = .center
                button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                button.addTarget(self, action: #selector(dateButtonTapped(_:)), for: .touchUpInside)
            }
            
        }
        
        @objc private func dateButtonTapped(_ sender: UIButton) {
            if sender == calendarButton {
                
                calendarButton.backgroundColor = .lightGray
                twoDaysAgoButton.backgroundColor = .clear
                yesterdayButton.backgroundColor = .clear
                todayButton.backgroundColor = .clear
                
                calendarView.isHidden.toggle()
                if !calendarView.isHidden {
                    calendarView.becomeFirstResponder()
                }
            } else {
                calendarView.isHidden = true
            }
            
            if sender == todayButton {
                self.viewModel.date = Date()
                todayButton.backgroundColor = .lightGray
                twoDaysAgoButton.backgroundColor = .clear
                yesterdayButton.backgroundColor = .clear
                calendarButton.backgroundColor = .clear
                calendarButton.setTitle("Calendar", for: .normal)
                
            } else if sender == twoDaysAgoButton {
                self.viewModel.date = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
                twoDaysAgoButton.backgroundColor = .lightGray
                todayButton.backgroundColor = .clear
                yesterdayButton.backgroundColor = .clear
                calendarButton.backgroundColor = .clear
                calendarButton.setTitle("Calendar", for: .normal)
                print("two days ago button tapped")
            } else if sender == yesterdayButton {
                self.viewModel.date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
                todayButton.backgroundColor = .clear
                twoDaysAgoButton.backgroundColor = .clear
                calendarButton.backgroundColor = .clear
                calendarButton.setTitle("Calendar", for: .normal)
                yesterdayButton.backgroundColor = .lightGray
                print("Yesterday button tapped")
            }
        }
        
        
         func formatDate(_ date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd" // Adjust the date format as needed
            return dateFormatter.string(from: date)
        }
        
        
        
    }

