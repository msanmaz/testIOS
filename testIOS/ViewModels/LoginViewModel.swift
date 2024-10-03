//
//  LoginViewModel.swift
//  testIOS
//
//  Created by Mert Osanmaz on 03/10/2024.
//
import SwiftUI
import Combine

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var username: String = ""
    @Published var isCreatingAccount: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var isLoggedIn: Bool = false

    private let authUseCase: AuthUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    init(authUseCase: AuthUseCaseProtocol = AuthUseCase()) {
        self.authUseCase = authUseCase
    }

    func login() {
        isLoading = true
        authUseCase.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.handleError(error)
                }
            }, receiveValue: { [weak self] response in
                self?.handleSuccessfulAuth(response)
            })
            .store(in: &cancellables)
    }

    func createAccount() {
        isLoading = true
        authUseCase.createUser(email: email, password: password, username: username)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.handleError(error)
                }
            }, receiveValue: { [weak self] response in
                self?.handleSuccessfulAuth(response)
            })
            .store(in: &cancellables)
    }

    func logout() {
        isLoading = true
        authUseCase.logout()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.handleError(error)
                }
            }, receiveValue: { [weak self] _ in
                self?.isLoggedIn = false
                // Clear any stored user data here
            })
            .store(in: &cancellables)
    }

    private func handleSuccessfulAuth(_ response: AuthResponse) {
        if response.success {
            isLoggedIn = true
            // Store the token securely here (e.g., in Keychain)
            // You might want to create a separate TokenManager for this
            alertMessage = "Authentication successful!"
        } else {
            alertMessage = response.message ?? "Authentication failed."
        }
        showAlert = true
    }

    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .unauthorized:
                alertMessage = "Invalid credentials. Please try again."
            case .serverError(let message):
                alertMessage = "Server error: \(message)"
            case .decodingError(let message):
                alertMessage = "Data error: \(message)"
            case .invalidURL:
                alertMessage = "Invalid URL. Please try again."
            case .noData:
                alertMessage = "No data received. Please try again."
            }
        } else {
            alertMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
        showAlert = true
    }
}
