//
//  PersistableObject .swift
//  SwiftData
//
//  Created by Hiral Naik on 8/6/25.
//

import Foundation
import RealmSwift

final class PersistableObject: Object {
    @Persisted(primaryKey: true) var key: String = ""
    @Persisted var data: Data?
}
