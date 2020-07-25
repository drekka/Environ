//
//  UserDefaultsStoreFactoryTests.swift
//  LocusTests
//
//  Created by Derek Clarkson on 7/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

import XCTest
@testable import Locus
import Nimble

class UserDefaultsStoreFactoryTests: XCTestCase {

    let factory = UserDefaultsStoreFactory()
    let parent = MockStore<Int>(key: "abc", value: 5)

    func testCreateStoreWithReadonlyAccessLevel() {
        let store = factory.createStoreForSetting(withKey: "abc", access: .readonly, parent: parent)
        expect(store).to(beAKindOf(UserDefaultsReadonlyStore<Int>.self))
    }

    func testCreateStoreWithWritableAccessLevel() {
        let store = factory.createStoreForSetting(withKey: "abc", access: .writable, parent: parent)
        expect(store).to(beAKindOf(UserDefaultsWritableStore<Int>.self))
    }

    func testCreateStoreWithReleaseLockedAccessLevel() {
        let store = factory.createStoreForSetting(withKey: "abc", access: .releaseLocked, parent: parent)
        expect(store) === parent
    }

    func testCreateStoreWithTransientAccessLevel() {
        let store = factory.createStoreForSetting(withKey: "abc", access: .transient, parent: parent)
        expect(store) === parent
    }
}
