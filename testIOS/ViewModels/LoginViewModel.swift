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
                    self?.alertMessage = "Login failed. Please check your credentials and try again."
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
                    self?.alertMessage = "Account creation failed. Please try again or contact support."
                    self?.showAlert = true
                }
            }
            .store(in: &cancellables)
    }

    private func handleError(_ error: Error) {
        isLoading = false
        if let networkError = error as? NetworkError {
            switch networkError {
            case .invalidURL:
                alertMessage = "We're having trouble connecting to our servers. Please try again later or contact support."
            case .noData:
                alertMessage = "No data received from the server. Please check your internet connection and try again."
            case .decodingError(let message):
                alertMessage = "We encountered an issue processing the server response. Error: \(message). Please try again or contact support if the problem persists."
            case .serverError(let message):
                alertMessage = "Our server is experiencing issues. Message: \(message). Please try again later or contact support."
            case .unauthorized:
                alertMessage = "Invalid credentials. Please check your email and password and try again."
            case .badRequest(let message):
                alertMessage = "There was an issue with your request. Details: \(message). Please verify your information and try again."
            case .notFound:
                alertMessage = "The requested resource was not found. Please check your information or try again later."
            case .unknown(let message):
                alertMessage = "An unexpected error occurred. Details: \(message). Please try again or contact support if the issue continues."
            }
        } else {
            alertMessage = "An unexpected error occurred: \(error.localizedDescription). Please try again or contact support."
        }
        showAlert = true
    }
}
