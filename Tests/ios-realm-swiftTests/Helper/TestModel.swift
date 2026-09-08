//
//  TestModel.swift
//  SwiftData
//
//  Created by Hiral Naik on 8/25/25.
//

import Foundation
@testable import ios_realm_swift

struct TestModel: Codable, PersistenceObject, Sendable {
    var id: String
    var name: String
    
    init(id: String, name: String) throws {
        self.id = id
        self.name = name
    }
    
    init?(persistenceObj: Data) {
        guard let model = try? JSONDecoder().decode(TestModel.self, from: persistenceObj) else {
            return nil
        }
        self = model
    }
    
    func key() -> String {
        return id
    }
    
    func persistenceObject() -> Data {
        return (try? JSONEncoder().encode(self)) ?? Data()
    }
}
