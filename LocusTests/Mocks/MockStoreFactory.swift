//
//  MockStoreFactory.swift
//  LocusTests
//
//  Created by Derek Clarkson on 7/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

@testable import Locus

struct MockStoreFactory: StoreFactory {

    init() {}

    func createStoreForSetting<V>(withKey key: String, scope: Scope, parent: Store<V>) -> Store<V> {
        switch scope {
        case .transient, .writable:
            return TransientStore(parent: parent)
        default:
            return parent
        }
    }
}
