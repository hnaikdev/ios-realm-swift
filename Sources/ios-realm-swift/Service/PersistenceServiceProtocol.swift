//
//  PersistenceServiceProtocol.swift
//  SwiftData
//
//  Created by Hiral Naik on 8/6/25.
//

public protocol PersistenceServiceProtocol {
    func store<P: PersistenceObject>(_ object: P) throws
    func remove<P: PersistenceObject>(_ object: P) throws
    func retrieve<P: PersistenceObject>(_ key: String) throws -> P?
    func retrieve<P: PersistenceObject>(_ keys: [String]) throws -> [P]
    func retrieve<P: PersistenceObject>(objectOfType: P.Type) throws -> [P]
}
