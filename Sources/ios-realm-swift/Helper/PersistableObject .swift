//
//  PersistableObject .swift
//  SwiftData
//
//  Created by Hiral Naik on 8/6/25.
//

import Foundation
import RealmSwift

@objcMembers class PersistableObject: Object {
    dynamic var key: String = ""
    dynamic var data: Data?
    
    override static func primaryKey() -> String? {
        return "key"
    }
}
