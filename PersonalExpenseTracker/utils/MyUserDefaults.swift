//
//  UserDefaults.swift
//  PersonalExpenseTracker
//
//  Created by Sarvar on 02/07/24.
//

import Foundation


class MyUserDefaults{
    
    //MARK: - Keys
    private enum Keys{
        static let isUserSignedIn = "isUserSignedIn"
        static let isUserSignedUp = "isUserSignedUp"
        static let userEmail = "userEmail"
        static let userName = "userName"
        static let userAge = "userAge"
        static let userID = "userID"
    }
    
    //MARK: - Properties
    static let shared = MyUserDefaults()
    
    private let defaults = UserDefaults.standard
    
    var userID: String? {
        get{
            return defaults.string(forKey: Keys.userID)
        }
        
        set{
            defaults.set(newValue, forKey: Keys.userID)
        }
    }
    
    var isUserSignedIn: Bool {
        get{
            return defaults.bool(forKey: Keys.isUserSignedIn)
        }
        
        set{
            defaults.set(newValue, forKey: Keys.isUserSignedIn)
        }
    }
    
    var isUserSignedUp: Bool {
        get{
            return defaults.bool(forKey: Keys.isUserSignedUp)
        }
        
        set{
            defaults.set(newValue, forKey: Keys.isUserSignedUp)
        }
    }
    
    var userEmail: String? {
            get {
                return defaults.string(forKey: Keys.userEmail)
            }
            set {
                defaults.set(newValue, forKey: Keys.userEmail)
            }
        }
    
    var userName: String? {
            get {
                return defaults.string(forKey: Keys.userName)
            }
            set {
                defaults.set(newValue, forKey: Keys.userName)
            }
        }
    
    var userAge: Int? {
            get {
                return defaults.object(forKey: Keys.userAge) as? Int
            }
            set {
                defaults.set(newValue, forKey: Keys.userAge)
            }
        }
    
    
    
    
    // MARK: - Initialization
        private init() {}
        
        // MARK: - Clear All Data
        func clearAll() {
            defaults.removeObject(forKey: Keys.isUserSignedIn)
            defaults.removeObject(forKey: Keys.userEmail)
            defaults.removeObject(forKey: Keys.userName)
            defaults.removeObject(forKey: Keys.isUserSignedUp)
            defaults.removeObject(forKey: Keys.userAge)
        }
    
    
}
