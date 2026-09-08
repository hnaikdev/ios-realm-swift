//
//  PersistenceService.swift
//  SwiftData
//
//  Created by Hiral Naik on 8/6/25.
//

import RealmSwift
import Foundation

public final class PersistenceService: PersistenceServiceProtocol, @unchecked Sendable {
    
    private let realmConfiguration: Realm.Configuration
    private let maxSize = 10 * 1024 * 1024
    
    public init() {
        self.realmConfiguration = RealmConfiguration.configuration
    }
    
    public func store<P>(_ object: P) throws where P : PersistenceObject {
        let realm = try makeRealm()
        let keyString = compositeKey(object)
        let objectData = object.persistenceObject()
        
        guard objectData.count <= maxSize else {
            throw PersistenceError.storeFailed
        }
        
        try realm.write {
            let persistedObject = PersistableObject()
            persistedObject.key = keyString
            persistedObject.data = objectData
            realm.add(persistedObject, update: .modified)
        }
    }
    
    public func remove<P>(_ object: P) throws where P : PersistenceObject {
        let keyString = compositeKey(object)
        let realm = try makeRealm()
        
        let persistedObject = realm.object(ofType: PersistableObject.self, forPrimaryKey: keyString)
        
        guard persistedObject != nil else {
            throw PersistenceError.removeFailed
        }
        
        try realm.write {
            realm.delete(persistedObject!)
        }
    }
    
    public func retrieve<P>(_ key: String) throws -> P? where P : PersistenceObject {
        let compositeKeyString = compositeKey(type: P.self, key: key)
        let realm = try makeRealm()
        
        let persistedObject = realm.object(ofType: PersistableObject.self, forPrimaryKey: compositeKeyString)
        
        guard let persistedObject = persistedObject else {
            return nil
        }
        
        guard let objectData = persistedObject.data else {
            return nil
        }
        
        let result = P(persistenceObj: objectData)
        return result
    }
    
    public func retrieve<P>(_ keys: [String]) throws -> [P] where P : PersistenceObject {
        let realm = try makeRealm()
        var results: [P] = []
        results.reserveCapacity(keys.count)
        
        for key in keys {
            let compositeKeyString = compositeKey(type: P.self, key: key)
            
            let persistedObject = realm.object(ofType: PersistableObject.self, forPrimaryKey: compositeKeyString)
            
            if let persistedObject = persistedObject,
               let objectData = persistedObject.data,
               let decodedObject = P(persistenceObj: objectData) {
                results.append(decodedObject)
            }
        }
        
        return results
    }
    
    public func retrieve<P>(objectOfType: P.Type) throws -> [P] where P : PersistenceObject {
        let realm = try makeRealm()
        let typeName = String(describing: P.self)
        let prefix = "\(typeName)-"
        
        // Use NSPredicate to avoid string interpolation issues
        let predicate = NSPredicate(format: "key BEGINSWITH %@", prefix)
        let realmResults = realm.objects(PersistableObject.self).filter(predicate)
        
        var results: [P] = []
        
        // Convert to Array immediately to force evaluation
        let resultsArray: [PersistableObject] = Array(realmResults)
        
        for persistedObject in resultsArray {
            if let objectData = persistedObject.data,
               let decodedObject = P(persistenceObj: objectData) {
                results.append(decodedObject)
            }
        }
        
        return results
    }
    
    private func compositeKey<P: PersistenceObject>(_ object: P) -> String {
        let objectType = type(of: object)
        let typeString = String(describing: objectType)
        let keyString = object.key()
        return "\(typeString)-\(keyString)"
    }

    private func compositeKey<P: PersistenceObject>(type: P.Type, key: String) -> String {
        let typeString = String(describing: type)
        return "\(typeString)-\(key)"
    }
    
    private func makeRealm() throws -> Realm {
        do {
            let realm = try RealmConfiguration.createRealm(withConfiguration: realmConfiguration)
            return realm
        } catch let error as PersistenceError {
            throw error
        } catch {
            throw PersistenceError.invalidConfiguration(error: error)
        }
    }
}
