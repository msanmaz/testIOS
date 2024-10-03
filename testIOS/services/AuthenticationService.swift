//
//  AuthenticationService.swift
//  testIOS
//
//  Created by Mert Osanmaz on 03/10/2024.
//
import Foundation
import Combine

class AuthenticationService: ObservableObject {
    @Published private(set) var isAuthenticated: Bool = false
    @Published private(set) var currentUser: User?
    
    private var cancellables = Set<AnyCancellable>()
    private let authUseCase: AuthUseCaseProtocol
    
    init(authUseCase: AuthUseCaseProtocol = AuthUseCase()) {
        self.authUseCase = authUseCase
        checkInitialAuthState()
    }
    
    private func checkInitialAuthState() {
        DispatchQueue.main.async { [weak self] in
            if let user = UserDefaultsManager.shared.getUser(), UserDefaultsManager.shared.isUserLoggedIn() {
                self?.isAuthenticated = true
                self?.currentUser = user
            }
        }
    }
    
    func login(email: String, password: String) -> AnyPublisher<Bool, Error> {
        authUseCase.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] response in
                self?.isAuthenticated = response.success
                if response.success {
                    self?.currentUser = response.user
                    UserDefaultsManager.shared.saveUser(response.user, token: response.token)
                }
            })
            .map(\.success)
            .eraseToAnyPublisher()
    }
    
    func createUser(email: String, password: String, username: String) -> AnyPublisher<Bool, Error> {
        authUseCase.createUser(email: email, password: password, username: username)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] response in
                if response.success {
                    self?.currentUser = response.user
                    UserDefaultsManager.shared.saveUser(response.user, token: response.token)
                }
            })
            .map(\.success)
            .eraseToAnyPublisher()
    }
    
    func logout() {
        authUseCase.logout()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Logout error: \(error)")
                }
            } receiveValue: { [weak self] _ in
                self?.isAuthenticated = false
                self?.currentUser = nil
                UserDefaultsManager.shared.clearUserData()
            }
            .store(in: &cancellables)
    }
}
