//
//  RealmConfiguration.swift
//  SwiftData
//
//  Created by Hiral Naik on 8/6/25.
//

import Foundation
import RealmSwift

struct RealmConfiguration {
    static var configuration: Realm.Configuration {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let file = url.appendingPathComponent("swiftdata.realm")
        let config = Realm.Configuration(fileURL: file)
        return config
    }
    
    static func createRealm(withConfiguration config: Realm.Configuration) throws -> Realm {
        var realm: Realm!
        do {
            realm = try Realm(configuration: config)
        } catch {
            throw PersistenceError.invalidConfiguration(error: error)
        }
        return realm
    }
}
