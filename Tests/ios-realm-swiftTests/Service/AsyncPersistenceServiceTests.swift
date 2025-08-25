//
//  AsyncPersistenceServiceTests.swift
//  SwiftData
//
//  Created by Hiral Naik on 8/25/25.
//

import Testing
@testable import ios_realm_swift

@Test("Store and retrieve object from Realm")
func asyncCallbackStoreAndRetrieve() async {
    let service = AsyncPersistenceService()
    let model = try! TestModel(id: "1", name: "Alice")
    
    let result = await withCheckedContinuation { continuation in
        service.store(model) { error in
            continuation.resume(returning: error)
        }
    }
    
    let (object, retrieveError) = await withCheckedContinuation { continuation in
        service.retrieve("1") { (object: TestModel?, error) in
            continuation.resume(returning: (object, error))
        }
    }
    
    #expect(result == nil)
    #expect(object?.id == "1")
    #expect(object?.name == "Alice")
    #expect(retrieveError == nil)
}

@Test("Update and retrieve object from Realm")
func asyncCallbackUpdateAndRetrieve() async throws {
    let service = AsyncPersistenceService()
    let model = try! TestModel(id: "1", name: "Alice")
    
    _ = await withCheckedContinuation { continuation in
        service.store(model) { error in
            continuation.resume(returning: error)
        }
    }
    
    var object = await withCheckedContinuation { continuation in
        service.retrieve("1") { (object: TestModel?, error) in
            continuation.resume(returning: object)
        }
    }
    
    object?.name = "Bob"
    
    _ = await withCheckedContinuation { continuation in
        service.store(object!) { error in
            continuation.resume(returning: error)
        }
    }
   
    let (updatedObject, retrieveError) = await withCheckedContinuation { continuation in
        service.retrieve("1") { (object: TestModel?, error) in
            continuation.resume(returning: (object, error))
        }
    }
    
    #expect(updatedObject?.id == "1")
    #expect(updatedObject?.name == "Bob")
    #expect(retrieveError == nil)
}

@Test("Store and retrieve multiple objects from Realm")
func asyncCallbackStoreAndRetrieveMultipleObjects() async throws {
    let service = AsyncPersistenceService()
    let model = try TestModel(id: "1", name: "Alice")
    let model2 = try TestModel(id: "2", name: "Mat")

    _ = await withCheckedContinuation { continuation in
        service.store(model) { error in
            continuation.resume(returning: error)
        }
    }
    
    _ = await withCheckedContinuation { continuation in
        service.store(model2) { error in
            continuation.resume(returning: error)
        }
    }
    
    let objects: [TestModel] = await withCheckedContinuation { continuation in
        service.retrieve(["1", "2"], completion: { objects, error in
            continuation.resume(returning: objects)
        })
    }
    
    let objects2: [TestModel] = await withCheckedContinuation { continuation in
        service.retrieve(objectOfType: TestModel.self, completion: { objects, error in
            print(objects)
            continuation.resume(returning: objects)
        })
    }

    #expect(objects.count == 2)
    #expect(objects2.count == 2)
}

@Test("Remove object from Realm")
func asyncCallbackRemoveObject() async throws {
    let service = AsyncPersistenceService()
    let model = try TestModel(id: "2", name: "Bob")

    _ = await withCheckedContinuation { continuation in
        service.store(model) { error in
            continuation.resume(returning: error)
        }
    }
    
    _ = await withCheckedContinuation { continuation in
        service.remove(model) { error in
            continuation.resume(returning: error)
        }
    }
    
    let obj = await withCheckedContinuation { continuation in
        service.retrieve("2") { (object: TestModel?, error) in
            continuation.resume(returning: object)
        }
    }
    
    #expect(obj == nil)
}

@Test("Try to remove object from Realm that doesn't exist")
func asyncCallbackRemoveNonExistObject() async throws {
    let service = AsyncPersistenceService()
    let model = try TestModel(id: "2", name: "Bob")
    let model1 = try TestModel(id: "3", name: "Bob")

    _ = await withCheckedContinuation { continuation in
        service.store(model) { error in
            continuation.resume(returning: error)
        }
    }
    
    let error = await withCheckedContinuation { continuation in
        service.remove(model1) { error in
            continuation.resume(returning: error)
        }
    }
    
    #expect(error != nil)
}
