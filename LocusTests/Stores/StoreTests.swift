//
//  StoreTests.swift
//  LocusTests
//
//  Created by Derek Clarkson on 3/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

import XCTest
import Nimble
@testable import Locus

class StoreTests: XCTestCase {

    var store: Store<String>!

    override func setUp() {
        super.setUp()
        store = Store()
}

    func testKey() {
        expect(_ = self.store.key).to(throwAssertion())
    }

    func testValue() {
        expect(_ = self.store.value).to(throwAssertion())
    }

    func testStoreFatal() {
        expect(self.store.store(newValue: "def")).to(throwAssertion())
    }

    func testUpdateFatal() {
        expect(self.store.update(defaultValue: "def")).to(throwAssertion())
    }

    func testResetFatal() {
        expect(self.store.reset()).to(throwAssertion())
    }
}
