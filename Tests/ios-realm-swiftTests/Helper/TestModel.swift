//
//  TestModel.swift
//  SwiftData
//
//  Created by Hiral Naik on 8/25/25.
//

import Testing
import Foundation
@testable import ios_realm_swift

struct TestModel: Codable, PersistenceObject {
    let id: String
    var name: String
    
    init(id: String, name: String) throws {
        self.id = id
        self.name = name
    }
    
    func key() -> String {
        id
    }
    
    func persistenceObject() -> Data {
        try! JSONEncoder().encode(self)
    }
    
    init?(persistenceObj: Data) {
        guard let decoded = try? JSONDecoder().decode(TestModel.self, from: persistenceObj) else { return nil }
        self = decoded
    }
}
