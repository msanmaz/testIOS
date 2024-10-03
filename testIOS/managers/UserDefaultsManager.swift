//
//  UserDefaultsManager.swift
//  testIOS
//
//  Created by Mert Osanmaz on 03/10/2024.
//
import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private init() {}
    
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let userId = "userId"
        static let userEmail = "userEmail"
        static let userName = "userName"
        static let authToken = "authToken"
        static let userCreatedAt = "userCreatedAt"
        static let userUpdatedAt = "userUpdatedAt"
    }
    
    func saveUser(_ user: User, token: String) {
        defaults.set(user.id, forKey: Keys.userId)
        defaults.set(user.email, forKey: Keys.userEmail)
        defaults.set(user.name, forKey: Keys.userName)
        defaults.set(user.createdAt, forKey: Keys.userCreatedAt)
        defaults.set(user.updatedAt, forKey: Keys.userUpdatedAt)
        defaults.set(token, forKey: Keys.authToken)
    }
    
    func getUser() -> User? {
        guard let id = defaults.object(forKey: Keys.userId) as? Int,
              let email = defaults.string(forKey: Keys.userEmail),
              let name = defaults.string(forKey: Keys.userName),
              let createdAt = defaults.string(forKey: Keys.userCreatedAt),
              let updatedAt = defaults.string(forKey: Keys.userUpdatedAt) else {
            return nil
        }
        return User(id: id, email: email, name: name, createdAt: createdAt, updatedAt: updatedAt)
    }
    
    func getToken() -> String? {
        return defaults.string(forKey: Keys.authToken)
    }
    
    func clearUserData() {
        defaults.removeObject(forKey: Keys.userId)
        defaults.removeObject(forKey: Keys.userEmail)
        defaults.removeObject(forKey: Keys.userName)
        defaults.removeObject(forKey: Keys.userCreatedAt)
        defaults.removeObject(forKey: Keys.userUpdatedAt)
        defaults.removeObject(forKey: Keys.authToken)
    }
    
    func isUserLoggedIn() -> Bool {
        return getUser() != nil && getToken() != nil
    }
}
