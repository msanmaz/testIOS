//
//  UserDefaultsManager.swift
//  testIOS
//
//  Created by Mert Osanmaz on 03/10/2024.
//
import Foundation

enum UserDefaultsKeys: String, CaseIterable {
    case userId = "userId"
    case userEmail = "userEmail"
    case userName = "userName"
    case userCreatedAt = "userCreatedAt"
    case userUpdatedAt = "userUpdatedAt"
}

protocol UserDefaultsEngine {
    func set(_ value: Any?, forKey key: UserDefaultsKeys)
    func object(forKey key: UserDefaultsKeys) -> Any?
    func removeObject(forKey key: UserDefaultsKeys)
}

extension UserDefaults: UserDefaultsEngine {
    func set(_ value: Any?, forKey key: UserDefaultsKeys) {
        set(value, forKey: key.rawValue)
    }
    
    func object(forKey key: UserDefaultsKeys) -> Any? {
        return object(forKey: key.rawValue)
    }
    
    func removeObject(forKey key: UserDefaultsKeys) {
        removeObject(forKey: key.rawValue)
    }
}

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let defaults: UserDefaultsEngine
    
    private init(defaults: UserDefaultsEngine = UserDefaults.standard) {
        self.defaults = defaults
    }
    
    func saveUser(_ user: User) {
        defaults.set(user.id, forKey: .userId)
        defaults.set(user.email, forKey: .userEmail)
        defaults.set(user.name, forKey: .userName)
        defaults.set(user.createdAt, forKey: .userCreatedAt)
        defaults.set(user.updatedAt, forKey: .userUpdatedAt)
    }
    
    func getUser() -> User? {
        guard let id = defaults.object(forKey: .userId) as? Int,
              let email = defaults.object(forKey: .userEmail) as? String,
              let name = defaults.object(forKey: .userName) as? String,
              let createdAt = defaults.object(forKey: .userCreatedAt) as? String,
              let updatedAt = defaults.object(forKey: .userUpdatedAt) as? String else {
            return nil
        }
        return User(id: id, email: email, name: name, createdAt: createdAt, updatedAt: updatedAt)
    }
    
    func clearUserData() {
        UserDefaultsKeys.allCases.forEach { defaults.removeObject(forKey: $0) }
    }
}
