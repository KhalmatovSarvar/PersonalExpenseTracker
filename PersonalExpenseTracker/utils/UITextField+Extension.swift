import UIKit

extension UITextField{
    
    func setPlaceHolderColor(){
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.appText.withAlphaComponent(0.4)])
    }
}
