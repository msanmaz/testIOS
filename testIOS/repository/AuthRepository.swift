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
    func logout() -> AnyPublisher<AuthResponse, Error>
}

class AuthRepository: AuthRepositoryProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }
    
    func login(email: String, password: String) -> AnyPublisher<AuthResponse, Error> {
        return networkService.login(email: email, password: password)
    }
    
    func createUser(email: String, password: String, username: String) -> AnyPublisher<AuthResponse, Error> {
        return networkService.createUser(email: email, password: password, username: username)
    }
    
    func verifyToken() -> AnyPublisher<AuthResponse, Error> {
        return networkService.verifyToken()
    }
    
    func logout() -> AnyPublisher<AuthResponse, Error> {
        return networkService.logout()
    }
}
