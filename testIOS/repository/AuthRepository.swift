//
//  AuthRepository.swift
//  testIOS
//
//  Created by Mert Osanmaz on 03/10/2024.
//

import Foundation
import Combine

protocol AuthRepositoryProtocol {
    func login(email: String, password: String) -> AnyPublisher<AuthResponse, Error>
    func createUser(email: String, password: String, username: String) -> AnyPublisher<AuthResponse, Error>
    func verifyToken() -> AnyPublisher<AuthResponse, Error>
    func logout() -> AnyPublisher<LogoutResponse, Error>
    func getCachedUser() -> User?
    func isUserLoggedIn() -> Bool
}

class AuthRepository: AuthRepositoryProtocol {
    
    private let networkService: NetworkServiceProtocol
    private let userDefaultsManager: UserDefaultsManager
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared,
         userDefaultsManager: UserDefaultsManager = .shared) {
        self.networkService = networkService
        self.userDefaultsManager = userDefaultsManager
    }
    
    func login(email: String, password: String) -> AnyPublisher<AuthResponse, Error> {
        let endpoint = Endpoint.login(email: email, password: password)
        return networkService.request(endpoint)
            .handleEvents(receiveOutput: { [weak self] response in
                if response.success {
                    self?.userDefaultsManager.saveUser(response.user)
                }
            })
            .eraseToAnyPublisher()
    }
    
    func createUser(email: String, password: String, username: String) -> AnyPublisher<AuthResponse, Error> {
        let endpoint = Endpoint.createUser(email: email, password: password, username: username)
        return networkService.request(endpoint)
            .handleEvents(receiveOutput: { [weak self] response in
                if response.success {
                    self?.userDefaultsManager.saveUser(response.user)
                }
            })
            .eraseToAnyPublisher()
    }
    
    func verifyToken() -> AnyPublisher<AuthResponse, Error> {
        let endpoint = Endpoint.verifyToken()
        return networkService.request(endpoint)
    }
    
    func logout() -> AnyPublisher<LogoutResponse, Error> {
        let endpoint = Endpoint.logout()
        return networkService.request(endpoint)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.userDefaultsManager.clearUserData()
            })
            .eraseToAnyPublisher()
    }
    
    func getCachedUser() -> User? {
        return userDefaultsManager.getUser()
    }
    
    func isUserLoggedIn() -> Bool {
        return userDefaultsManager.getUser() != nil
    }
}
