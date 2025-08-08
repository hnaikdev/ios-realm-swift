//
//  APIService.swift
//  Example
//
//  Created by Hiral Naik on 8/8/25.
//

import Foundation
import ios_realm_swift

protocol APIServiceProtocol {
    func fetchData() async throws -> [User]
    func read(for keys: [Int]) async throws -> [User]
    func delete(for key: Int) async throws
    func fetchData(completion: @escaping ([User], APIServiceError?) -> Void)
}

class APIService: APIServiceProtocol {
    
    let networkService: NetworkClientProtocol
    let persistentService: PersistenceServiceProtocol
    
    init(networkService: NetworkClientProtocol, persistentService: PersistenceServiceProtocol) {
        self.networkService = networkService
        self.persistentService = persistentService
    }
    
    func fetchData() async throws -> [User] {
        do {
            let users = try persistentService.retrieve(objectOfType: User.self)
            if users.count > 0 {
                return users
            }
            
            let urlString = "https://fake-json-api.mock.beeceptor.com/users"
            let url = URL(string: urlString)
            let request = URLRequest(url: url!)
            
            let result = try await networkService.fetch(request, type: [User].self)
            
            for user in result {
                try persistentService.store(user)
            }
            
            return result
        } catch {
            throw error
        }
    }
    
    func read(for keys: [Int]) async throws -> [User] {
        do {
            let stringKeys = keys.map { $0.description }
            return try persistentService.retrieve(stringKeys)
        } catch {
            throw error
        }
    }
    
    func delete(for key: Int) async throws {
        do {
            if let object: User = try persistentService.retrieve(key.description) {
                try persistentService.remove(object)
            }
        } catch {
            throw error
        }
    }
    
    func fetchData(completion: @escaping ([User], APIServiceError?) -> Void) {
        let urlString = "https://fake-json-api.mock.beeceptor.com/users"
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)
        
        networkService.fetch(request, type: [User].self) { users, error in
            guard error == nil else {
                completion([], error)
                return
            }
            completion(users ?? [], nil)
        }
    }
}
