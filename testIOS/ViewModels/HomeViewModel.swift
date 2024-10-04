//
//  HomeViewModel.swift
//  testIOS
//
//  Created by Mert Osanmaz on 04/10/2024.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var yachts: [Yacht] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let yachtRepository: YachtRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(yachtRepository: YachtRepositoryProtocol = YachtRepository()) {
        self.yachtRepository = yachtRepository
    }
    
    func fetchYachts(forceRefresh: Bool = false) {
        if forceRefresh {
            isLoading = true
        }
        errorMessage = nil
        
        yachtRepository.fetchYachts()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.handleError(error)
                }
            } receiveValue: { [weak self] yachts in
                self?.yachts = yachts
            }
            .store(in: &cancellables)
    }
    
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .invalidURL:
                errorMessage = "Oops! There's an issue with the URL. Please try again later or contact support."
            case .noData:
                errorMessage = "We couldn't retrieve any data. Please check your internet connection and try again."
            case .decodingError(let message):
                errorMessage = "We're having trouble processing the data. Error: \(message). Please try again or contact support if the issue persists."
            case .serverError(let message):
                errorMessage = "Our server is experiencing issues. Message: \(message). Please try again later."
            case .unauthorized:
                errorMessage = "You're not authorized to access this information. Please log in again or check your permissions."
            case .badRequest(let message):
                errorMessage = "There was an issue with the request. Details: \(message). Please try again or contact support."
            case .notFound:
                errorMessage = "The yacht information you're looking for couldn't be found. It may have been removed or doesn't exist."
            case .unknown(let message):
                errorMessage = "An unexpected error occurred. Details: \(message). Please try again or contact support if the issue continues."
            }
        } else {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription). Please try again or contact support."
        }
    }
}
