//
//  AsyncPersistenceService.swift
//  SwiftData
//
//  Created by Hiral Naik on 8/6/25.
//

import Foundation
import RealmSwift

public class AsyncPersistenceService: AsyncPersistenceServiceProtocol {
    
    private let persistenceService: PersistenceServiceProtocol
    
    public init() {
        self.persistenceService = PersistenceService()
    }
    
    public func store<P>(_ object: P, completion: @escaping (PersistenceError?) -> Void) where P : PersistenceObject {
        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else {
                completion(.storeFailed)
                return
            }
            
            do {
                try strongSelf.persistenceService.store(object)
                completion(nil)
            } catch {
                completion(error as? PersistenceError)
            }
        }
    }
    
    public func remove<P>(_ object: P, completion: @escaping (PersistenceError?) -> Void) where P : PersistenceObject {
        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else {
                completion(.removeFailed)
                return
            }
            
            do {
                try strongSelf.persistenceService.remove(object)
                completion(nil)
            } catch {
                completion(error as? PersistenceError)
            }
        }
    }
    
    public func retrieve<P>(_ key: String, completion: @escaping (P?, PersistenceError?) -> Void) where P : PersistenceObject {
        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else {
                completion(nil, .retrieveFailed)
                return
            }
            
            do {
                let object: P? = try strongSelf.persistenceService.retrieve(key)
                completion(object, nil)
            } catch {
                completion(nil, .retrieveFailed)
            }
        }
    }
    
    public func retrieve<P>(_ keys: [String], completion: @escaping ([P], PersistenceError?) -> Void) where P : PersistenceObject {
        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else {
                completion([], .retrieveFailed)
                return
            }
            
            do {
                let objects: [P] = try strongSelf.persistenceService.retrieve(keys)
                completion(objects, nil)
            } catch {
                completion([], .retrieveFailed)
            }
        }
    }
    
    public func retrieve<P>(objectOfType: P.Type, completion: @escaping ([P], PersistenceError?) -> Void) where P : PersistenceObject {
        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else {
                completion([], .retrieveFailed)
                return
            }
            
            do {
                let objects: [P] = try strongSelf.persistenceService.retrieve(objectOfType: objectOfType)
                completion(objects, nil)
            } catch {
                completion([], .retrieveFailed)
            }
        }
    }
}
