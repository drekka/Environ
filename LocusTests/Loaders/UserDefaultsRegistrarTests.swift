//
//  UserDefaultsRegistrarTests.swift
//  LocusTests
//
//  Created by Derek Clarkson on 14/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

import XCTest
@testable import Locus
import Nimble

class UserDefaultsRegistrarTests: XCTestCase {

    private var registrar: UserDefaultsRegistrar!

    override func setUp() {
        super.setUp()

        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.removePersistentDomain(forName: Bundle(for: UserDefaultsRegistrarTests.self).bundleIdentifier!)
        type(of: self).clearRegisteredDefaults()

        registrar = UserDefaultsRegistrar()
    }

    func testDoesNothingIfNothingFoundInBundle() {
        registrar.register() // Will search the xctest bundle by default and find nothing.
        expect(UserDefaults.standard.object(forKey: "slider_preference")).to(beNil())
    }

    func testRegistering() {

        let registeredValues = registrar.register(bundle: Bundle(for: UserDefaultsRegistrarTests.self))
        let defaults = UserDefaults.standard

        expect(defaults.float(forKey: "slider_preference")) == 0.5
        expect(defaults.string(forKey: "name_preference")) == "Hello"
        expect(defaults.bool(forKey: "enabled_preference")).to(beTrue())
        expect(defaults.float(forKey: "child.slider_preference")) == 123.456
        expect(defaults.string(forKey: "child.name_preference")) == "Hello from child"
        expect(defaults.bool(forKey: "child.enabled_preference")).to(beFalse())

        expect((registeredValues["slider_preference"] as! Float)) == 0.5
        expect((registeredValues["name_preference"] as! String)) == "Hello"
        expect((registeredValues["enabled_preference"] as! Bool)).to(beTrue())
        expect((registeredValues["child.slider_preference"] as! Double)) == 123.456
        expect((registeredValues["child.name_preference"] as! String)) == "Hello from child"
        expect((registeredValues["child.enabled_preference"] as! Bool)).to(beFalse())
    }

    func testDuplicateKeyFatals() {
        expect( _ = self.registrar.register(bundle: Bundle(for: UserDefaultsRegistrarTests.self), rootPlistName: "DuplicateKey")).to(throwAssertion())
    }

    static func clearRegisteredDefaults() {
        // We havew to use this code to clear the resgistration domain because it is not cleared by executing a remove domain function.
        var registered = UserDefaults.standard.volatileDomain(forName: UserDefaults.registrationDomain)
        registered.removeValue(forKey: "slider_preference")
        registered.removeValue(forKey: "name_preference")
        registered.removeValue(forKey: "enabled_preference")
        registered.removeValue(forKey: "child.slider_preference")
        registered.removeValue(forKey: "child.name_preference")
        registered.removeValue(forKey: "child.enabled_preference")
        UserDefaults.standard.setVolatileDomain(registered, forName: UserDefaults.registrationDomain)
    }
}
