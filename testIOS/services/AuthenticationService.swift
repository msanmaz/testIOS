//
//  AuthenticationService.swift
//  testIOS
//
//  Created by Mert Osanmaz on 03/10/2024.
//
import Foundation
import Combine

class AuthenticationService: ObservableObject {
    @Published private(set) var isAuthenticated: Bool
    @Published private(set) var currentUser: User?
    
    private var cancellables = Set<AnyCancellable>()
    private let authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol = AuthRepository()) {
        self.authRepository = authRepository
        self.isAuthenticated = authRepository.isUserLoggedIn()
        self.currentUser = authRepository.getCachedUser()
    }
    
    func login(email: String, password: String) -> AnyPublisher<Bool, Error> {
        authRepository.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] response in
                self?.isAuthenticated = response.success
                if response.success {
                    self?.currentUser = response.user
                }
            })
            .map(\.success)
            .eraseToAnyPublisher()
    }
    
    func createUser(email: String, password: String, username: String) -> AnyPublisher<Bool, Error> {
        authRepository.createUser(email: email, password: password, username: username)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] response in
                if response.success {
                    self?.currentUser = response.user
                    self?.isAuthenticated = true
                }
            })
            .map(\.success)
            .eraseToAnyPublisher()
    }
    
    func logout() {
        authRepository.logout()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Logout error: \(error)")
                }
            } receiveValue: { [weak self] _ in
                self?.isAuthenticated = false
                self?.currentUser = nil
            }
            .store(in: &cancellables)
    }
    
    func verifyToken() {
        authRepository.verifyToken()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(_) = completion {
                    self?.isAuthenticated = false
                    self?.currentUser = nil
                }
            } receiveValue: { [weak self] response in
                self?.isAuthenticated = response.success
                if response.success {
                    self?.currentUser = response.user
                }
            }
            .store(in: &cancellables)
    }
}
