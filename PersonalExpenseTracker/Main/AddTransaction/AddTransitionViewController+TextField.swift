//
//  AddTransitionViewController+TextField.swift
//  PersonalExpenseTracker
//
//  Created by Sarvar on 08/07/24.
//

import UIKit

extension AddTransactionViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == amountTextField {
            let newAmount = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
            viewModel.amount = newAmount
        } else if textField == descriptionTextField {
            let newDescription = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
            print("i am here ")
            viewModel.info = newDescription
        }
    return true
    }
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            switch textField {
            case amountTextField :
                amountTextField.becomeFirstResponder()
            case descriptionTextField:
                descriptionTextField.becomeFirstResponder()
            default:
                textField.resignFirstResponder()
            }
            
        }
        
    }

