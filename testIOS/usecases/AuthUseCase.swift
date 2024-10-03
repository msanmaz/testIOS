//
//  AuthUseCase.swift
//  testIOS
//
//  Created by Mert Osanmaz on 03/10/2024.
//

import Foundation
import Combine

protocol AuthUseCaseProtocol {
    func login(email: String, password: String) -> AnyPublisher<AuthResponse, Error>
    func createUser(email: String, password: String, username: String) -> AnyPublisher<AuthResponse, Error>
    func verifyToken() -> AnyPublisher<AuthResponse, Error>
    func logout() -> AnyPublisher<AuthResponse, Error>
}

class AuthUseCase: AuthUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    
    init(repository: AuthRepositoryProtocol = AuthRepository()) {
        self.repository = repository
    }
    
    func login(email: String, password: String) -> AnyPublisher<AuthResponse, Error> {
        return repository.login(email: email, password: password)
    }
    
    func createUser(email: String, password: String, username: String) -> AnyPublisher<AuthResponse, Error> {
        return repository.createUser(email: email, password: password, username: username)
    }
    
    func verifyToken() -> AnyPublisher<AuthResponse, Error> {
        return repository.verifyToken()
    }
    
    func logout() -> AnyPublisher<AuthResponse, Error> {
        return repository.logout()
    }
}
