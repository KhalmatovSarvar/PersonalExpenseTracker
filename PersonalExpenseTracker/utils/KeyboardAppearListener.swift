//
//  KeyboardAppearListener.swift
//  PersonalExpenseTracker
//
//  Created by Sarvar on 30/06/24.
//

import UIKit

class KeyboardAppearListener {
    private var showKeyboard: NotificationToken?
    private var hideKeyboard: NotificationToken?
    private weak var viewController: UIViewController?
    init(
        _ viewController: UIViewController,
        notificationCenter: NotificationCenter = .default) {
        self.viewController = viewController
        showKeyboard = notificationCenter.observe(
            name: UIResponder.keyboardWillShowNotification) { [weak self] (notification) in
                self?.keyboardWillShow(notification: notification)
        }
        hideKeyboard = notificationCenter.observe(
            name: UIResponder.keyboardWillHideNotification) { [weak self] (notification) in
            self?.keyboardWillHide(notification: notification)
        }
    }
    private func keyboardWillShow(notification: Notification) {}
    private func keyboardWillHide(notification: Notification) {}
}
