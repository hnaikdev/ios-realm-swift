//
//  NetworkClient.swift
//  Example
//
//  Created by Hiral Naik on 8/8/25.
//

import Foundation

enum APIServiceError: Error {
    case networkError
    case decodeingError
}

protocol NetworkClientProtocol {
    func fetch<T: Decodable>(_ request: URLRequest, type: T.Type) async throws -> T
    func fetch<T: Decodable>(_ request: URLRequest, type: T.Type, completion: @escaping (T?, APIServiceError?) -> Void)
}

final class NetworkClient: NetworkClientProtocol {
    
    func fetch<T: Decodable>(_ request: URLRequest, type: T.Type, completion: @escaping (T?, APIServiceError?) -> Void) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                completion(nil, APIServiceError.networkError)
                return
            }
            
            guard let data else {
                completion(nil, APIServiceError.networkError)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                completion(result, nil)
            } catch {
                completion(nil, APIServiceError.decodeingError)
            }
        }.resume()
    }
    
    func fetch<T: Decodable>(_ request: URLRequest, type: T.Type) async throws -> T {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                throw APIServiceError.networkError
            }
            
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIServiceError.decodeingError
        }
    }
}


