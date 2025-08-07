//
//  PersistenceService.swift
//  SwiftData
//
//  Created by Hiral Naik on 8/6/25.
//

import RealmSwift
import Foundation

public class PersistenceService: PersistenceServiceProtocol {
    
    private let realmConfiguration: Realm.Configuration
    private let maxSize = 10 * 1024 * 1024
    
    public init() {
        self.realmConfiguration = RealmConfiguration.configuration
    }
    
    public func store<P>(_ object: P) throws where P : PersistenceObject {
        let realm = try makeRealm()
        let persistedObject = PersistableObject()
        persistedObject.key = object.key()
        persistedObject.data = object.persistenceObject()
        
        guard let data = persistedObject.data else {
            throw PersistenceError.persistenceFailed
        }
        
        guard data.count <= maxSize else {
            throw PersistenceError.storeFailed
        }
        
        try realm.write {
            realm.add(persistedObject, update: .all)
        }
    }
    
    public func remove<P>(_ object: P) throws where P : PersistenceObject {
        var isRemoved = false
        let key = object.key()
        let realm = try makeRealm()
        
        if let persistedObject = realm.object(ofType: PersistableObject.self, forPrimaryKey: key) {
            try realm.write {
                realm.delete(persistedObject)
            }
            isRemoved = true
        }
        
        if !isRemoved {
            throw PersistenceError.removeFailed
        }
    }
    
    public func retrieve<P>(_ key: String) throws -> P? where P : PersistenceObject {
        var returnObject: P?
        let key = compositeKey(type: P.self, key: key)
        let realm = try makeRealm()
        
        if let persistedObject = realm.object(ofType: PersistableObject.self, forPrimaryKey: key), let data = persistedObject.data {
            returnObject = P(persistenceObj: data)
        }
        
        return returnObject
    }
    
    public func retrieve<P>(_ keys: [String]) throws -> [P] where P : PersistenceObject {
        return keys.compactMap { try! retrieve($0) }
    }
    
    public func retrieve<P>(objectOfType: P.Type) throws -> [P] where P : PersistenceObject {
        var results = [P]()
        let realm = try makeRealm()
        let objects = realm.objects(PersistableObject.self).filter("key BEGINSWITH '\(P.self)-' AND data != nil")
        results = objects.compactMap { P(persistenceObj: $0.data!) }
        return results
    }
    
    private func compositeKey<P: PersistenceObject>(_ object: P) -> NSString {
        return compositeKey(type: P.self, key: object.key())
    }

    private func compositeKey<P: PersistenceObject>(type: P.Type, key: String) -> NSString {
        return "\(type)-\(key)" as NSString
    }
    
    private func makeRealm() throws -> Realm {
        do {
            return try RealmConfiguration.createRealm(withConfiguration: realmConfiguration)
        } catch {
            throw error
        }
    }
}
