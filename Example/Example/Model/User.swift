//
//  User.swift
//  Example
//
//  Created by Hiral Naik on 8/8/25.
//

import Foundation
import ios_realm_swift

struct User: Codable, PersistenceObject {
    let id: Int?
    let name: String?
    let company: String?
    let username: String?
    let email: String?
    let address: String?
    let zip: String?
    let state: String?
    let country: String?
    let phone: String?
    let photo: String?
    
    init?(persistenceObj: Data) {
        guard let user = try? JSONDecoder().decode(User.self, from: persistenceObj) else { return nil }
        self = user
    }
    
    func key() -> String {
        return "\(id ?? -1)"
    }
    
    func persistenceObject() -> Data {
        return try! JSONEncoder().encode(self)
    }
}
