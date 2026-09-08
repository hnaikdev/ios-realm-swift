//
//  AsyncPersistenceServiceProtocol.swift
//  SwiftData
//
//  Created by Hiral Naik on 8/6/25.
//

public protocol AsyncPersistenceServiceProtocol: Sendable {
    func store<P: PersistenceObject>(_ object: P, completion: @escaping @Sendable (PersistenceError?) -> Void)
    func remove<P: PersistenceObject>(_ object: P, completion: @escaping @Sendable (PersistenceError?) -> Void)
    func retrieve<P: PersistenceObject>(_ key: String, completion: @escaping @Sendable (P?, PersistenceError?) -> Void)
    func retrieve<P: PersistenceObject>(_ keys: [String], completion: @escaping @Sendable ([P], PersistenceError?) -> Void)
    func retrieve<P: PersistenceObject>(objectOfType: P.Type, completion: @escaping @Sendable ([P], PersistenceError?) -> Void)
}
