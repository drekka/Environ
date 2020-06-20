//
//  LocusContainer.swift
//  Locus
//
//  Created by Derek Clarkson on 9/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

import os

public class LocusContainer {

    /// Enables or disables the auto-registering of user defaults defaultValues from settings plists.
    /// On by default.
    public var registerAppSettings = true {
        didSet {
            appSettingsRegistered = !registerAppSettings
        }
    }

    /// If true, causes Locus to fatal if a user default is found that has not been registered.
    public var validateAppSettingsKeys = true

    // An override that allows for the searching of app settings in a different bundle.
    public var appSettingsBundle = Bundle.main

    // Go true when the UserDefaultsRegistrar has been run.
    private var appSettingsRegistered = false

    ///
    public static var shared: SettingsContainer = {
        os_log("%@Starting singleton container...", type: .debug, logPrefix)
        return LocusContainer()
    }()

    private let storeFactories: [StoreFactory]
    private var stores: [String: Any] = [:]

    public init(storeFactories: [StoreFactory] = [TransientStoreFactory(), UserDefaultsStoreFactory()]) {
        self.storeFactories = storeFactories.reversed()
    }

    public convenience init(storeFactories: StoreFactory...) {
        self.init(storeFactories: storeFactories)
    }

    fileprivate func registerUserDefaultValues() {

        // Return if told not to register user defaults.
        if appSettingsRegistered { return }

        // Register and validate if required.
        os_log("%@Registering application settings in user defaults...", type: .debug, logPrefix)
        let registeredDefaults = UserDefaultsRegistrar().register(bundle: appSettingsBundle)
        if validateAppSettingsKeys {
            os_log("%@Validating application settings found in user defaults...", type: .debug, logPrefix)
            let knownKeys = stores.keys
            registeredDefaults.keys.forEach { key in
                if !knownKeys.contains(key) {
                    fatalError("User default with key \(key) not registered!")
                }
            }
        }
        appSettingsRegistered = true
    }
}

extension LocusContainer: SettingsContainer, SettingsSubscriptable {

    public func register(_ registrars: (SettingsContainer) -> Void...) {
        registrars.forEach { $0(self) }
    }

    public func register<T>(key: String, scope: Scope, defaultValue: T) {

        guard !stores.keys.contains(key) else {
            fatalError(fatalPrefix + "Key " + key + " already registered")
        }

        stores[key] = storeFactories.reduce(DefaultStore(key: key, defaultValue: defaultValue)) { store, factory -> Store<T> in
            return factory.createStoreForSetting(withKey:key, scope: scope, parent: store)
        }
    }

    public func load(fromLoaders loaders: SettingsLoader..., completion: @escaping () -> Void) {
        executeNextLoader(from: loaders, completion: completion)
    }

    private func executeNextLoader(from array: [SettingsLoader], completion: @escaping () -> Void) {

        if array.isEmpty {
            os_log("%@Finished loading settings.", type: .debug, logPrefix)
            completion()
            return
        }

        var loaders = array
        let loader = loaders.removeFirst()
        os_log("%@Executing loader %@ ...", type: .debug, logPrefix, String(describing: loader))
        loader.load(into: self) {
            self.executeNextLoader(from: loaders, completion: completion)
        }
    }

    public func resolve<T>(_ key: String) -> T {
        registerUserDefaultValues()
        return storageChain(forKey: key).value
    }

    public func store<T>(key: String, value: T) {
        storageChain(forKey: key).update(withDefaultValue: value)
    }

    public func reset(key: String) {
        (stores[key] as? Store<Any>)?.reset()
    }

    private func storageChain<T>(forKey key: String) -> Store<T> {
        if let store = stores[key] {
            if let castStore = store as? Store<T> {
                return castStore
            }
            fatalError(fatalPrefix + "Cast failure. Cannot cast a " + String(describing: type(of: store)) + " to a Store<" + String(describing: T.self) + ">.")
        }
        fatalError(fatalPrefix + "Unknown key: " + key)
    }
}

extension LocusContainer: SettingsLoadable {

    // MARK: - SettingsLoadable

    public func update<V>(key: String, defaultValue value: V) {
    }
}
