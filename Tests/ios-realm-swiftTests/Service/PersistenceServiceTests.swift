//
//  PersistenceServiceTests.swift
//  SwiftData
//
//  Created by Hiral Naik on 8/25/25.
//

import Testing
@testable import ios_realm_swift

@Test("Store and retrieve object from Realm")
func storeAndRetrieve() async throws {
    let realmService = PersistenceService()
    let obj = try TestModel(id: "1", name: "Alice")
    try realmService.store(obj)
    
    let retrievedObj: TestModel? = try realmService.retrieve("1")
    #expect(retrievedObj != nil)
    #expect(retrievedObj?.name == "Alice")
}

@Test("Update and retrieve object from Realm")
func updateAndRetrieve() async throws {
    let realmService = PersistenceService()
    let obj = try TestModel(id: "1", name: "Alice")
    try realmService.store(obj)
    
    var retrievedObj: TestModel? = try realmService.retrieve("1")
    retrievedObj?.name = "Bob"
    try realmService.store(retrievedObj!)
    
    let updatedObj: TestModel? = try realmService.retrieve("1")
    #expect(updatedObj != nil)
    #expect(updatedObj?.name == "Bob")
}

@Test("Store and retrieve multiple objects from Realm")
func storeAndRetrieveMultipleObjects() async throws {
    let realmService = PersistenceService()
    
    let obj = try TestModel(id: "1", name: "Alice")
    let obj1 = try TestModel(id: "2", name: "Bob")
    
    try realmService.store(obj)
    try realmService.store(obj1)
    
    let objects: [TestModel] = try realmService.retrieve(objectOfType: TestModel.self)
    print(objects)
    #expect(objects.count == 2)
    
    let keysObjects: [TestModel] = try realmService.retrieve(["1", "2"])
    #expect(keysObjects.count == 2)
}

@Test("Remove object from cache")
func removeObject() async throws {
    let realmService = PersistenceService()
    let obj = try TestModel(id: "1", name: "Alice")
    try realmService.store(obj)
    let retrievedObj: TestModel? = try realmService.retrieve("1")
    
    #expect(retrievedObj != nil)
    #expect(retrievedObj?.name == "Alice")
    
    try realmService.remove(obj)
    let removed: TestModel? = try realmService.retrieve("1")
    
    #expect(removed == nil)
    #expect(removed?.name == nil)
}

@Test("Retrieve non-existent object returns nil")
func retrieveNonexistent() async throws {
    let realmService = PersistenceService()
    let obj: TestModel? = try realmService.retrieve("404")
    #expect(obj == nil)
    #expect(obj?.name == nil)
}
