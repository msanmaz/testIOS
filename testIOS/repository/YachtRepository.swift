//
//  YachtRepository.swift
//  testIOS
//
//  Created by Mert Osanmaz on 04/10/2024.
//

import Foundation
import Combine

protocol YachtRepositoryProtocol {
    func fetchYachts() -> AnyPublisher<[Yacht], Error>
}

class YachtRepository: YachtRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private var cachedYachts: [Yacht]?
    private var lastFetchTime: Date?
    private let cacheValidityDuration: TimeInterval = 5 * 600 // 5 minutes
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func fetchYachts() -> AnyPublisher<[Yacht], Error> {
        if let cachedYachts = cachedYachts,
           let lastFetchTime = lastFetchTime,
           Date().timeIntervalSince(lastFetchTime) < cacheValidityDuration {
            return Just(cachedYachts)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return networkService.fetchYachts()
            .handleEvents(receiveOutput: { [weak self] yachts in
                self?.cachedYachts = yachts
                self?.lastFetchTime = Date()
            })
            .eraseToAnyPublisher()
    }
}
