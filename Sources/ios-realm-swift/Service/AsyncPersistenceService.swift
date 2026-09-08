//
//  AsyncPersistenceService.swift
//  SwiftData
//
//  Created by Hiral Naik on 8/6/25.
//

import Foundation
import RealmSwift

public final class AsyncPersistenceService: AsyncPersistenceServiceProtocol, @unchecked Sendable {
    
    private let persistenceService: PersistenceServiceProtocol
    private let queue: DispatchQueue
    
    public init() {
        self.persistenceService = PersistenceService()
        self.queue = DispatchQueue(label: "com.asyncpersistence.queue", qos: .userInitiated)
    }
    
    public func store<P>(_ object: P, completion: @escaping @Sendable (PersistenceError?) -> Void) where P : PersistenceObject {
        queue.async { [weak self] in
            guard let self else {
                completion(.storeFailed)
                return
            }
            
            do {
                try self.persistenceService.store(object)
                completion(nil)
            } catch let error as PersistenceError {
                completion(error)
            } catch {
                completion(.storeFailed)
            }
        }
    }
    
    public func remove<P>(_ object: P, completion: @escaping @Sendable (PersistenceError?) -> Void) where P : PersistenceObject {
        queue.async { [weak self] in
            guard let self else {
                completion(.removeFailed)
                return
            }
            
            do {
                try self.persistenceService.remove(object)
                completion(nil)
            } catch let error as PersistenceError {
                completion(error)
            } catch {
                completion(.removeFailed)
            }
        }
    }
    
    public func retrieve<P>(_ key: String, completion: @escaping @Sendable (P?, PersistenceError?) -> Void) where P : PersistenceObject {
        queue.async { [weak self] in
            guard let self else {
                completion(nil, .retrieveFailed)
                return
            }
            
            do {
                let object: P? = try self.persistenceService.retrieve(key)
                completion(object, nil)
            } catch let error as PersistenceError {
                completion(nil, error)
            } catch {
                completion(nil, .retrieveFailed)
            }
        }
    }
    
    public func retrieve<P>(_ keys: [String], completion: @escaping @Sendable ([P], PersistenceError?) -> Void) where P : PersistenceObject {
        queue.async { [weak self] in
            guard let self else {
                completion([], .retrieveFailed)
                return
            }
            
            do {
                let objects: [P] = try self.persistenceService.retrieve(keys)
                completion(objects, nil)
            } catch let error as PersistenceError {
                completion([], error)
            } catch {
                completion([], .retrieveFailed)
            }
        }
    }
    
    public func retrieve<P>(objectOfType: P.Type, completion: @escaping @Sendable ([P], PersistenceError?) -> Void) where P : PersistenceObject {
        queue.async { [weak self] in
            guard let self else {
                completion([], .retrieveFailed)
                return
            }
            
            do {
                let objects: [P] = try self.persistenceService.retrieve(objectOfType: objectOfType)
                completion(objects, nil)
            } catch let error as PersistenceError {
                completion([], error)
            } catch {
                completion([], .retrieveFailed)
            }
        }
    }
}
