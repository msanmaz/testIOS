//
//  NetworkServices.swift
//  testIOS
//
//  Created by Mert Osanmaz on 03/10/2024.
//
import Foundation
import Combine

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(String)
    case serverError(String)
    case unauthorized
    case badRequest(String)
    case notFound
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let message):
            return "Decoding error: \(message)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .unauthorized:
            return "Unauthorized access"
        case .badRequest(let message):
            return "Bad request: \(message)"
        case .notFound:
            return "Resource not found"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}

protocol NetworkServiceProtocol {
    func request<T: Codable>(_ endpoint: Endpoint) -> AnyPublisher<T, Error>
    func fetchYachts() -> AnyPublisher<[Yacht], Error>
}

class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    private let baseURL = "http://192.168.0.122:3000"
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpShouldSetCookies = true
        configuration.httpCookieAcceptPolicy = .always
        self.session = URLSession(configuration: configuration)
    }
    
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    func request<T: Codable>(_ endpoint: Endpoint) -> AnyPublisher<T, Error> {
        guard let url = URL(string: baseURL + endpoint.path) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        
        if let body = endpoint.body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.unknown("Invalid response")
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    return data
                case 400:
                    throw self.handleBadRequest(data)
                case 401:
                    throw NetworkError.unauthorized
                case 404:
                    throw NetworkError.notFound
                case 500...599:
                    throw self.handleServerError(data)
                default:
                    throw NetworkError.unknown("Unexpected status code: \(httpResponse.statusCode)")
                }
            }
            .decode(type: T.self, decoder: jsonDecoder)
            .mapError { error -> Error in
                if let networkError = error as? NetworkError {
                    return networkError
                } else if let decodingError = error as? DecodingError {
                    return NetworkError.decodingError(decodingError.localizedDescription)
                } else {
                    return NetworkError.unknown(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func handleBadRequest(_ data: Data) -> NetworkError {
        if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
            return .badRequest(errorResponse.message)
        } else {
            return .badRequest("Invalid request")
        }
    }
    
    private func handleServerError(_ data: Data) -> NetworkError {
        if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
            return .serverError(errorResponse.message)
        } else {
            return .serverError("An unexpected server error occurred")
        }
    }
    
    func fetchYachts() -> AnyPublisher<[Yacht], Error> {
        let endpoint = Endpoint(
            path: "/api/public/yatchs",
            method: .get,
            headers: nil,
            body: nil
        )
        return request(endpoint)
    }
}

struct ErrorResponse: Codable {
    let message: String
}


enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

struct Endpoint {
    let path: String
    let method: HTTPMethod
    let headers: [String: String]?
    let body: [String: Any]?
}

// Auth-related endpoints
extension Endpoint {
    static func login(email: String, password: String) -> Endpoint {
        return Endpoint(
            path: "/api/auth/login",
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: ["email": email, "password": password]
        )
    }
    
    
    static func createUser(email: String, password: String, username: String) -> Endpoint {
        return Endpoint(
            path: "/api/auth/create-user",
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: ["email": email, "password": password, "username": username]
        )
    }
    
    static func verifyToken() -> Endpoint {
        return Endpoint(
            path: "/api/auth/verify-token",
            method: .get,
            headers: nil,
            body: nil
        )
    }
    
    static func logout() -> Endpoint {
        return Endpoint(
            path: "/api/auth/logout",
            method: .get,
            headers: nil,
            body: nil
        )
    }
}
