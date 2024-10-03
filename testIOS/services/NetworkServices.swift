//
//  NetworkServices.swift
//  testIOS
//
//  Created by Mert Osanmaz on 03/10/2024.
//
import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError(String)
    case serverError(String)
    case unauthorized
}

class NetworkService {
    static let shared = NetworkService()
    private init() {}
    
    private let baseURL = "http://192.168.0.122:3000"
    private var token: String?
    
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    func setToken(_ token: String) {
        self.token = token
    }
    
    func clearToken() {
        self.token = nil
    }
    
    func request<T: Codable>(_ endpoint: Endpoint) -> AnyPublisher<T, Error> {
        guard let url = URL(string: baseURL + endpoint.path) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        
        if let token = token {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = endpoint.body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.serverError("Invalid response")
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    return data
                case 401:
                    throw NetworkError.unauthorized
                default:
                    throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
                }
            }
            .decode(type: T.self, decoder: jsonDecoder)
            .mapError { error -> Error in
                           if let decodingError = error as? DecodingError {
                               print("Decoding error: \(decodingError)")
                               switch decodingError {
                               case .keyNotFound(let key, let context):
                                   return NetworkError.decodingError("Key '\(key.stringValue)' not found: \(context.debugDescription)")
                               case .typeMismatch(let type, let context):
                                   return NetworkError.decodingError("Type '\(type)' mismatch: \(context.debugDescription)")
                               case .valueNotFound(let type, let context):
                                   return NetworkError.decodingError("Value of type '\(type)' not found: \(context.debugDescription)")
                               case .dataCorrupted(let context):
                                   return NetworkError.decodingError("Data corrupted: \(context.debugDescription)")
                               @unknown default:
                                   return NetworkError.decodingError("Unknown decoding error")
                               }
                           } else if let networkError = error as? NetworkError {
                               return networkError
                           } else {
                               return NetworkError.serverError(error.localizedDescription)
                           }
                       }
                       .eraseToAnyPublisher()
    }
    
    func login(email: String, password: String) -> AnyPublisher<AuthResponse, Error> {
        let endpoint = Endpoint.login(email: email, password: password)
        return request(endpoint)
            .handleEvents(receiveOutput: { [weak self] response in
                if response.success{
                    self?.setToken(response.token)
                    UserDefaultsManager.shared.saveUser(response.user, token: response.token)
                }
            })
            .eraseToAnyPublisher()
    }
    
    func createUser(email: String, password: String, username: String) -> AnyPublisher<AuthResponse, Error> {
        let endpoint = Endpoint.createUser(email: email, password: password, username: username)
        return request(endpoint)
            .handleEvents(receiveOutput: { [weak self] response in
                if response.success {
                    self?.setToken(response.token)
                }
            })
            .eraseToAnyPublisher()
    }
    
    func verifyToken() -> AnyPublisher<AuthResponse, Error> {
        let endpoint = Endpoint.verifyToken()
        return request(endpoint)
    }
    
    func logout() -> AnyPublisher<LogoutResponse, Error> {
          let endpoint = Endpoint.logout()
          return request(endpoint)
              .handleEvents(receiveOutput: { [weak self] response in
                  if response.success {
                      self?.clearToken()
                  }
              })
              .eraseToAnyPublisher()
      }
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
            path: "api/auth/verify-token",
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
