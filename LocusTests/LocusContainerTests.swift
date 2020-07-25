//
//  SettingsTests.swift
//  LocusTests
//
//  Created by Derek Clarkson on 7/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

import XCTest
@testable import Locus
import Nimble

enum TestKey: String {
    case def
}

class LocusContainerTests: XCTestCase {

    private var settings: LocusContainer!

    override func setUp() {
        super.setUp()
        UserDefaultsRegistrarTests.clearRegisteredDefaults()
        settings = LocusContainer(storeFactories: [MockStoreFactory()])
    }

    func testSingletonAccess() {
        expect(LocusContainer.shared).toNot(beNil())
        }

    // MARK: - Registration functions

    func testRegisteringASetting() {
        settings.register(key: "abc", access: .readonly, default: 5)
        let result:Int = settings.resolve("abc")
        expect(result) == 5
    }

    func testRegisteringASettingWithDefaultReadonly() {
        settings.register(key: "abc", default: 5)
        let result:Int = settings.resolve("abc")
        expect(result) == 5
    }

    func testRegisteringASettingWithRawRepresentable() {
        settings.register(key: TestKey.def, access: .readonly, default: 5)
        let result:Int = settings.resolve(TestKey.def)
        expect(result) == 5
    }

    func testRegisteringASettingWithDefaultReadonlyRawRepresentable() {
        settings.register(key: TestKey.def, default: 5)
        let result:Int = settings.resolve(TestKey.def)
        expect(result) == 5
    }

    func testDuplicateSettingRegistrationThrows() {
        LocusContainer.shared.register(key: "abc", default: 5)
        expect(LocusContainer.shared.register(key: "abc", default: "def")).to(throwAssertion())
    }

    // MARK: - Resolving

    func testResolvingASetting() {
        settings.register(key: "abc", access: .readonly, default: 5)
        let result:Int = settings.resolve("abc")
        expect(result) == 5
    }

    func testResolvingASettingWithRawRepresentable() {
        settings.register(key: TestKey.def, access: .readonly, default: 5)
        let result:Int = settings.resolve(TestKey.def)
        expect(result) == 5
    }

    func testResolveCastFailure() {
        settings.register(key: "abc", access: .readonly, default: 5)
        expect(_ = self.settings.resolve("abc") as String).to(throwAssertion())
    }

    func testResolveUnknownKeyFailure() {
        expect(_ = self.settings.resolve("abc") as String).to(throwAssertion())
    }

    // MARK: - Storing

    func testStore() {
        settings.register(key: "abc", access: .writable, default: 5)
        settings.store(key: "abc", value: 10)
        let result:Int = settings.resolve("abc")
        expect(result) == 10
    }

    func testStoreWithRawRepresentable() {
        settings.register(key: TestKey.def, access: .writable, default: 5)
        settings.store(key: TestKey.def, value: 10)
        let result:Int = settings.resolve(TestKey.def)
        expect(result) == 10
    }

    // MARK: - Resetting

    func testResettingASetting() {
        settings.register(key: "abc", access: .writable, default: 5)
        settings.store(key: "abc", value: 10)
        settings.reset(key: "abc")
    }

    func testResettingASettingWithRawRepresentable() {
        settings.register(key: TestKey.def, access: .writable, default: 5)
        settings.store(key: TestKey.def, value: 10)
        settings.reset(key: TestKey.def)
    }

    // MARK: - Subscriptable

    func testSubscriptableWithStringKey() {
        settings.register(key: "abc", access: .writable, default: 5)
        expect(self.settings["abc"] as Int) == 5
    }

    func testSubscriptableWithRawRepresentable() {
        settings.register(key: TestKey.def, access: .writable, default: 5)
        expect(self.settings[TestKey.def] as Int) == 5
    }

    func testSubscriptableStoreWithStringKey() {
        settings.register(key: "abc", access: .writable, default: 5)
        settings["abc"] = 10
        expect(self.settings["abc"] as Int) ==  10
    }

    func testSubscriptableStoreWithRawRepresentable() {
        settings.register(key: TestKey.def, access: .writable, default: 5)
        settings[TestKey.def] = 10
        expect(self.settings[TestKey.def] as Int) == 10
    }

    // MARK: - Registering user defaults

    func testUserDefaultsRegisteredWhenSettingAccessed() {

        var called = false
        settings.userDefaultsRegistrar = {
            called = true
            return [:]
        }

        settings.register(key: "abc", default: "hello")
        expect(called).to(beFalse())
        expect(self.settings.resolve("abc") as String) == "hello" // Should trigger user defaults registrations.
        expect(called).to(beTrue())
    }


    func testUserDefaultsDontRegisteredIfDisabled() {

        var called = false
        settings.userDefaultsRegistrar = {
            called = true
            return [:]
        }
        settings.register(key: "abc", access: .readonly, default: 5)
        expect(called).to(beFalse())
        settings.registerAppSettings = false
        expect(self.settings.resolve("abc") as Int) == 5 // Should NOT trigger user defaults registrations.
        expect(called).to(beFalse())
    }

    func testUserDefaultsRegisteredThrowsWhenNotPreregistered() {
        settings.userDefaultsRegistrar = {
            return ["def": 5]
        }
        settings.register(key: "abc", access: .readonly, default: 5)
        expect(_ = self.settings.resolve("abc") as Int).to(throwAssertion())
    }

    func testUserDefaultsRegisteredDoesntThrowWhenToldNotTo() {
        var called = false
        settings.userDefaultsRegistrar = {
            called = true
            return ["def": 5]
        }
        settings.register(key: "abc", access: .readonly, default: "hello")
        settings.validateAppSettingsKeys = false
        expect(self.settings.resolve("abc") as String) == "hello"
        expect(called).to(beTrue())
    }

    // MARK:- Loaders

    func testRunsLoaders() {

//        settings.register(key: "abc", defaultValue: "")
//        settings.register(key: "def", defaultValue: "")
//
//        let loader1 = MockLoader(settings: ["abc": "hello"], result: .success(()))
//        let loader2 = MockLoader(settings: ["def": "there"], result: .success(()))
//
//        var result: Result<Void, Error>!
//        settings.load(fromLoaders: loader1, loader2) { result = $0 }
//
//        expect(result).toEventuallyNot(beNil())
//
//        if let result = result, case Result<Void, Error>.failure = result {
//            fail("Expected a success!")
//        }
//
//        expect(loader1.called).to(beTrue())
//        expect(loader2.called).to(beTrue())
//
//        expect(self.settings["abc"] as String) == "hello"
//        expect(self.settings["def"] as String) == "bye"
    }
}
