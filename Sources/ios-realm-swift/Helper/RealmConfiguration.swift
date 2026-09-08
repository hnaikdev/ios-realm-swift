//
//  RealmConfiguration.swift
//  SwiftData
//
//  Created by Hiral Naik on 8/6/25.
//

import Foundation
import RealmSwift

struct RealmConfiguration: Sendable {
    static var configuration: Realm.Configuration {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            // Fallback to a default location
            let temporaryDirectory = FileManager.default.temporaryDirectory
            let file = temporaryDirectory.appendingPathComponent("swiftdata.realm")
            return makeConfiguration(fileURL: file)
        }
        
        let file = url.appendingPathComponent("swiftdata.realm")
        return makeConfiguration(fileURL: file)
    }
    
    private static func makeConfiguration(fileURL: URL) -> Realm.Configuration {
        return Realm.Configuration(
            fileURL: fileURL,
            schemaVersion: 2, // Increment when schema changes
            migrationBlock: { migration, oldSchemaVersion in
                // Migration from @objcMembers to @Persisted
                if oldSchemaVersion < 2 {
                    // Realm will automatically handle the migration
                    // since property names and types remain the same
                }
            }
        )
    }
    
    static func createRealm(withConfiguration config: Realm.Configuration) throws -> Realm {
        do {
            let realm = try Realm(configuration: config)
            return realm
        } catch {
            throw PersistenceError.invalidConfiguration(error: error)
        }
    }
}
