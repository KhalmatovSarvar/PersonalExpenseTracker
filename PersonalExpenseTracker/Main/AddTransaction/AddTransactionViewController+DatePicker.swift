//
//  AddTransactionViewController+DatePicker.swift
//  PersonalExpenseTracker
//
//  Created by Sarvar on 08/07/24.
//

import UIKit

extension AddTransactionViewController {
    
    func setUpDatePicker(){
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.datePickerMode = .date
        calendarView.preferredDatePickerStyle = .inline
        calendarView.backgroundColor = .secondarySystemBackground
        calendarView.maximumDate = Date() // Set maximum date to today
        calendarView.isHidden = true
        
        calendarView.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        // Create a DateFormatter and set its format to dd/MM
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "dd/MM"
           
           // Convert the selectedDate to a string
           let dateString = dateFormatter.string(from: selectedDate)
           
           // Set the formatted date string as the title of the calendarButton
           calendarButton.setTitle(dateString, for: .normal)
        self.viewModel.date = selectedDate
    }
    
    private func toggleDatePickerVisibility() {
        calendarView.isHidden.toggle()
    }

}

