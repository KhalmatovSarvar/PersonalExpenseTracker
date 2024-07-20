import UIKit

extension AddTransactionViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == amountTextField {
            let currentText = textField.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            // Allow only numbers and one decimal point (dot)
            let decimalCharacters = CharacterSet(charactersIn: ".")
            let numberSet = CharacterSet.decimalDigits.union(decimalCharacters)
            
            let isNumeric = newText.isEmpty || newText.rangeOfCharacter(from: numberSet.inverted) == nil
            let numberOfDots = newText.components(separatedBy: ".").count - 1
            let isValidAmount = isNumeric && numberOfDots <= 1
            
            if isValidAmount {
                viewModel.amount = newText
                return true
            } else {
                return false
            }
        } else if textField == descriptionTextField {
            let newDescription = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
            viewModel.info = newDescription
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case amountTextField:
            amountTextField.resignFirstResponder()
            descriptionTextField.becomeFirstResponder()
        case descriptionTextField:
            descriptionTextField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
