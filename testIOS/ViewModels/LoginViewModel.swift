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

    private var cancellables = Set<AnyCancellable>()

    func login(authService: AuthenticationService) {
        isLoading = true
        authService.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.handleError(error)
                }
            } receiveValue: { [weak self] success in
                if !success {
                    self?.alertMessage = "Login failed. Please try again."
                    self?.showAlert = true
                }
            }
            .store(in: &cancellables)
    }

    func createAccount(authService: AuthenticationService) {
        isLoading = true
        authService.createUser(email: email, password: password, username: username)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.handleError(error)
                }
            } receiveValue: { [weak self] success in
                if success {
                    self?.login(authService: authService) // Automatically log in after successful account creation
                } else {
                    self?.alertMessage = "Account creation failed. Please try again."
                    self?.showAlert = true
                }
            }
            .store(in: &cancellables)
    }

    private func handleError(_ error: Error) {
        isLoading = false
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
