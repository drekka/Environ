//
//  TransientStoreFactoryTests.swift
//  LocusTests
//
//  Created by Derek Clarkson on 7/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

import XCTest
@testable import Locus
import Nimble

class TransientStoreFactoryTests: XCTestCase {

    private var factory: StoreFactory = TransientStoreFactory()

    func testCreatingATransient() {
        let parent = MockStore(key: "abc", value: 5)
        let store = factory.createStoreForSetting(withKey: "abc", access: .transient, parent: parent)
        expect(store).toNot(beNil())
        expect(store).to(beAKindOf(TransientStore<Int>.self))
    }

    func testCreatingOtherStoreReturnsParent() {
        let parent = MockStore(key: "abc", value: 5)
        let store = factory.createStoreForSetting(withKey: "abc", access: .readonly, parent: parent)
        expect(store).toNot(beNil())
        expect(store) === store
    }
}
