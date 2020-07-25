//
//  ChainedStoreTests.swift
//  LocusTests
//
//  Created by Derek Clarkson on 6/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

import XCTest
@testable import Locus
import Nimble

class ChainedStoreTests: XCTestCase {

    private var store: ChainedStore<Int>!
    private var parent: Store<Int>!

    override func setUp() {
        super.setUp()
        parent = MockStore(key: "abc", value: 5)
        store = ChainedStore(parent: parent)
    }

    func testKey() {
        expect(self.store.key) == "abc"
    }

    func testValue() {
        expect(self.store.value) == 5
    }

    func testStore() {
        store.store(newValue: 10)
        expect(self.store.value) == 10
    }

    func testUpdate() {
        store.update(defaultValue: 10)
        expect(self.store.value) == 10
    }
}
