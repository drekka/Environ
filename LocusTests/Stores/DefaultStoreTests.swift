//
//  locusTests.swift
//  locusTests
//
//  Created by Derek Clarkson on 16/5/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

import XCTest
import Nimble
@testable import Locus

class DefaultStoreTests: XCTestCase {

    var store: Store<Int>!

    override func setUp() {
        super.setUp()
        store = DefaultStore(key: "abc", value: 5)
    }

    func testValue() {
        expect(self.store.value) == 5
    }

    func testStoreFatals() {
        expect(self.store.store(newValue: 10)).to(throwAssertion())
    }

    func testUpdate() {
        store.update(defaultValue: 10)
        expect(self.store.value) == 10
    }
}
