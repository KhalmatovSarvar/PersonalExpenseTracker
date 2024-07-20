//
//  view_utils.swift
//  PersonalExpenseTracker
//
//  Created by Sarvar on 30/06/24.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAlert(message: String?, isError: Bool = true) {
        guard let message = message else { return }
        let alert = isError ? UIAlertController(title: "Error", message: message, preferredStyle: .alert) : UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

import UIKit

class DoughnutChartCircular: UIView {
    
    // MARK: - Public Properties
    public var lineWidth: CGFloat {
        get {
            return _lineWidth
        }
        set(newValue) {
            _lineWidth = newValue
            setNeedsDisplay()
        }
    }
    
    // MARK: - Private Variables
    private var _data: [(percentage: Double, color: UIColor)]
    private var _lineWidth: CGFloat
    
    // MARK: - Initialization
    public init(data: [(percentage: Double, color: UIColor)], lineWidth: CGFloat = 10.0) {
        self._data = data
        self._lineWidth = lineWidth
        super.init(frame: CGRect.zero)
        self.backgroundColor = .clear
        self.clipsToBounds = false
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Method to Update Data
    public func updateData(_ data: [(percentage: Double, color: UIColor)]) {
        self._data = data
        setNeedsDisplay()
    }
    
    // MARK: - Drawing
    override public func draw(_ rect: CGRect) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2 - _lineWidth / 2
        let innerRadius = outerRadius * 0.4 // Adjust the multiplier for a smaller hole
        
        var startAngle: CGFloat = -CGFloat.pi / 2
        
        for data in _data {
            let endAngle = startAngle + CGFloat(data.percentage / 100.0) * 2 * CGFloat.pi
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: center.x + outerRadius * cos(startAngle), y: center.y + outerRadius * sin(startAngle)))
            path.addArc(withCenter: center, radius: outerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            path.addLine(to: CGPoint(x: center.x + innerRadius * cos(endAngle), y: center.y + innerRadius * sin(endAngle)))
            path.addArc(withCenter: center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: false)
            path.close()
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.fillColor = data.color.cgColor
            shapeLayer.path = path.cgPath
            layer.addSublayer(shapeLayer)
            
            startAngle = endAngle
        }
    }
}


extension UIColor {
    func encode() -> Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
    
    static func decode(data: Data) -> UIColor? {
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)
    }
}

extension UINavigationController {
    func backTwo() {
        let viewControllers = self.viewControllers
        if viewControllers.count >= 3 {
            self.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        } else {
            print("Not enough view controllers in the stack to go back two.")
        }
    }
}









