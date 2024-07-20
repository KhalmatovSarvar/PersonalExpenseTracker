import UIKit

class CustomTabBar: UITabBar {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Move the tab bar items down to avoid overlap with the rounded corners
        for item in subviews where item is UIControl {
            item.frame.origin.y = 10
        }
        
        // Set the background color
        self.backgroundColor = .systemBlue
        
        // Set rounded corners
        self.layer.cornerRadius = 20
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.layer.masksToBounds = true
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 60 // Adjust the height of the tab bar
        return sizeThatFits
    }
}
