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

    private var settings: SettingsContainer!

    override func setUp() {
        super.setUp()

        // Clear registered defaults.
        UserDefaultsRegistrarTests.clearRegisteredDefaults()

        settings = LocusContainer(storeFactories: [MockStoreFactory()])
    }

    func testSingletonAccess() {
        expect(LocusContainer.shared).toNot(beNil())
        }

    // MARK: - Registration functions

    func testRegisteringASetting() {
        settings.register(key: "abc", scope: .readonly, defaultValue: 5)
        let result:Int = settings.resolve("abc")
        expect(result) == 5
    }

    func testRegisteringASettingWithDefaultReadonly() {
        settings.register(key: "abc", defaultValue: 5)
        let result:Int = settings.resolve("abc")
        expect(result) == 5
    }

    func testRegisteringASettingWithRawRepresentable() {
        settings.register(key: TestKey.def, scope: .readonly, defaultValue: 5)
        let result:Int = settings.resolve(TestKey.def)
        expect(result) == 5
    }

    func testRegisteringASettingWithDefaultReadonlyRawRepresentable() {
        settings.register(key: TestKey.def, defaultValue: 5)
        let result:Int = settings.resolve(TestKey.def)
        expect(result) == 5
    }

    func testDuplicateSettingRegistrationThrows() {
        LocusContainer.shared.register(key: "abc", defaultValue: 5)
        expect(LocusContainer.shared.register(key: "abc", defaultValue: "def")).to(throwAssertion())
    }

    // MARK: - Resolving

    func testResolvingASetting() {
        settings.register(key: "abc", scope: .readonly, defaultValue: 5)
        let result:Int = settings.resolve("abc")
        expect(result) == 5
    }

    func testResolvingASettingWithRawRepresentable() {
        settings.register(key: TestKey.def, scope: .readonly, defaultValue: 5)
        let result:Int = settings.resolve(TestKey.def)
        expect(result) == 5
    }

    func testResolveCastFailure() {
        settings.register(key: "abc", scope: .readonly, defaultValue: 5)
        expect(_ = self.settings.resolve("abc") as String).to(throwAssertion())
    }

    func testResolveUnknownKeyFailure() {
        expect(_ = self.settings.resolve("abc") as String).to(throwAssertion())
    }

    // MARK: - Storing

    func testStore() {
        settings.register(key: "abc", scope: .writable, defaultValue: 5)
        settings.store(key: "abc", value: 10)
        let result:Int = settings.resolve("abc")
        expect(result) == 10
    }

    func testStoreWithRawRepresentable() {
        settings.register(key: TestKey.def, scope: .writable, defaultValue: 5)
        settings.store(key: TestKey.def, value: 10)
        let result:Int = settings.resolve(TestKey.def)
        expect(result) == 10
    }

    // MARK: - Resetting

    func testResettingASetting() {
        settings.register(key: "abc", scope: .writable, defaultValue: 5)
        settings.store(key: "abc", value: 10)
        settings.reset(key: "abc")
    }

    func testResettingASettingWithRawRepresentable() {
        settings.register(key: TestKey.def, scope: .writable, defaultValue: 5)
        settings.store(key: TestKey.def, value: 10)
        settings.reset(key: TestKey.def)
    }

    // MARK: - Subscriptable

    func testSubscriptableWithStringKey() {
        settings.register(key: "abc", scope: .writable, defaultValue: 5)
        expect(self.settings["abc"] as Int) == 5
    }

    func testSubscriptableWithRawRepresentable() {
        settings.register(key: TestKey.def, scope: .writable, defaultValue: 5)
        expect(self.settings[TestKey.def] as Int) == 5
    }

    func testSubscriptableStoreWithStringKey() {
        settings.register(key: "abc", scope: .writable, defaultValue: 5)
        settings["abc"] = 10
        expect(self.settings["abc"] as Int) ==  10
    }

    func testSubscriptableStoreWithRawRepresentable() {
        settings.register(key: TestKey.def, scope: .writable, defaultValue: 5)
        settings[TestKey.def] = 10
        expect(self.settings[TestKey.def] as Int) == 10
    }

    // MARK: - Registering user defaults

    func testUserDefaultsNotRegisteredWhenNoSettingAccessed() {
        let defaults = UserDefaults.standard
        expect(defaults.float(forKey: "slider_preference")) == 0.0
    }

    func testUserDefaultsNotRegisteredWhenturnedOff() {
        settings.register(key: "abc", scope: .readonly, defaultValue: 5)
        settings.registerAppSettings = false
        settings.appSettingsBundle = Bundle(for: type(of: self))
        expect(self.settings.resolve("abc") as Int) == 5 // Should NOT trigger user defaults registrations.
    }

    func testUserDefaultsRegisteredWhenSettingAccessed() {

        // Register keys to match those in settings bundle.
        settings.register(key: "slider_preference", defaultValue: 123)
        settings.register(key: "name_preference", defaultValue: "Hello")
        settings.register(key: "enabled_preference", defaultValue: true)
        settings.register(key: "child.slider_preference", defaultValue: 123.456)
        settings.register(key: "child.name_preference", defaultValue: "Hello from child")
        settings.register(key: "child.enabled_preference", defaultValue: false)

        settings.appSettingsBundle = Bundle(for: type(of: self))

        expect(self.settings.resolve("name_preference") as String) == "Hello" // Should trigger user defaults registrations.
        expect(UserDefaults.standard.float(forKey: "slider_preference")) == 0.5 // Should match value registered in user defaults.
    }

    func testUserDefaultsRegisteredThrowsWhenNotPreregistered() {
        settings.appSettingsBundle = Bundle(for: type(of: self))
        expect(self.settings.resolve("name_preference")).to(throwAssertion()) // Should trigger registration and throw on none registration of plist settings.
    }

    func testUserDefaultsRegisteredDoesntThrowWhenToldNotTo() {

        settings.register(key: "abc", scope: .readonly, defaultValue: 5)
        settings.appSettingsBundle = Bundle(for: type(of: self))

        settings.validateAppSettingsKeys = false

        expect(self.settings.resolve("abc") as Int) == 5 // Should trigger user defaults registrations.
        expect(UserDefaults.standard.float(forKey: "slider_preference")) == 0.5 // Should match value registered in user defaults.
    }
}
