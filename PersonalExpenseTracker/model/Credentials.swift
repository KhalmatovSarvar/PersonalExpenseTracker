//
//  Credentials.swift
//  PersonalExpenseTracker
//
//  Created by Sarvar on 02/07/24.

import Foundation
import Security

struct Credentials {
    let email: String
    let password: String
}

class KeychainService {
    
    static let shared = KeychainService()
    static let server = "personalexpensetracker-b3dbe.firebaseapp.com"
    
    
    private init() {}
    
    func addQuery(credentials: Credentials) {
        let account = credentials.email
        let password = credentials.password.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: account,
            kSecAttrServer as String: KeychainService.server,
            kSecValueData as String: password
        ]
        
        // Use the query to add the credentials securely to Keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            print("Credentials added to Keychain successfully.")
        } else {
            print("Failed to add credentials to Keychain. Status: \(status)")
        }
    }
    
    
    func getPassword(for email: String) -> String? {
            let query: [String: Any] = [
                kSecClass as String: kSecClassInternetPassword,
                kSecAttrAccount as String: email,
                kSecAttrServer as String: KeychainService.server,
                kSecReturnData as String: true
            ]
            
            var result: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &result)
            
            guard status == errSecSuccess, let data = result as? Data else {
                return nil
            }
            
            return String(data: data, encoding: .utf8)
        }
    
}
