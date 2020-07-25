//
//  LocusContainer.swift
//  Locus
//
//  Created by Derek Clarkson on 9/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

import os

public class LocusContainer: Container {

    public static var defaultStoreFactories: [StoreFactory] = [TransientStoreFactory(), UserDefaultsStoreFactory()]

    /// Enables or disables the auto-registering of user defaults defaultValues from settings plists.
    /// On by default.
    public var registerAppPreferences = true

    /// If true, causes Locus to fatal if a user default is found that has not been registered.
    public var validateAppSettingsKeys = true

    // An override that allows for the searching of app settings in a different bundle.
    public var appSettingsBundle = Bundle.main

    // Internally overriddable for testing the container
    lazy var userDefaultsRegistrar: () -> [String: Any] = { UserDefaultsRegistrar().register(bundle: self.appSettingsBundle) }

    /**
     Singleton for those who like them.

     Coding based on Singletons is not a good practice and should be avoided unless necessary.
     */
    public static var shared: SettingsContainer & Container = {
        os_log("🧩 Starting singleton container...", type: .debug)
        return LocusContainer()
    }()

    private let storeFactories: [StoreFactory]
    private var stores: [String: Any] = [:]

/**
     Default initializer.

     - parameter storeFactories: A list of `StoreFactory` instances that will be used to create the `Store` instances which manage settings.
     */
    public init(storeFactories: [StoreFactory] = LocusContainer.defaultStoreFactories) {
        self.storeFactories = storeFactories.reversed()
    }

    /**
     Convenience initializer.

     - parameter storeFactories: A list of `StoreFactory` instances that will be used to create the `Store` instances which manage settings.
     */
    public convenience init(storeFactories: StoreFactory...) {
        self.init(storeFactories: storeFactories)
    }

    public func load(fromLoaders loaders: Loader..., completion: @escaping (_ result: Result<Void, Error>) -> Void) {
        os_log("🧩 Running loaders ...", type: .debug)
        executeNextLoader(from: loaders, completion: completion)
    }

    public func update<V>(key: String, withNewDefault value: V) {
        os_log("🧩     Updating default value: %@ -> %@", type: .debug, key, String(describing: value))
        storageChain(forKey: key).update(defaultValue: value)
    }

    private func executeNextLoader(from array: [Loader], completion: @escaping (_ result: Result<Void, Error>) -> Void) {

        if array.isEmpty {
            os_log("🧩 Finished loading settings.", type: .debug)
            completion(.success(()))
            return
        }

        var loaders = array
        let loader = loaders.removeFirst()
        os_log("🧩 Executing loader %@ ...", type: .debug, String(describing: loader))
        loader.load(into: self) { result in

            if case .failure = result {
                os_log("🧩     Loader failed, returning error %@", type: .debug, String(describing: loader))
                completion(result)
                return
            }

            os_log("🧩     Loader finished, excuting next loader ...", type: .debug, String(describing: loader))
            self.executeNextLoader(from: loaders, completion: completion)
        }
    }
}

// MARK: - Container

extension LocusContainer: SettingsContainer {

    public func register<T>(key: String, access: AccessLevel, default defaultValue: T) {

        guard !stores.keys.contains(key) else {
            fatalError("🧨🧨🧨 Key " + key + " already registered")
        }

        stores[key] = storeFactories.reduce(DefaultStore(key: key, value: defaultValue)) { store, factory -> Store<T> in
            return factory.createStoreForSetting(withKey:key, access: access, parent: store)
        }
    }

    public func resolve<T>(_ key: String) -> T {
        registerUserDefaultValues()
        return storageChain(forKey: key).value
    }

    public func store<T>(key: String, value: T) {
        storageChain(forKey: key).store(newValue: value)
    }

    public func reset(key: String) {
        (stores[key] as? Store<Any>)?.reset()
    }

    // MARK: Internal

    fileprivate func registerUserDefaultValues() {

        // Return if app settings have already been loaded into user defaults or we are not loading them.
        guard registerAppPreferences else { return }

        // Register and validate if required.
        os_log("🧩 Registering application settings in user defaults...", type: .debug)
        let registeredDefaults = userDefaultsRegistrar()
        if validateAppSettingsKeys {
            os_log("🧩 Validating application settings found in user defaults...", type: .debug)
            let knownKeys = stores.keys
            registeredDefaults.keys.forEach { key in
                if !knownKeys.contains(key) {
                    fatalError("User default with key \(key) not registered!")
                }
            }
        }
        registerAppPreferences = false
    }

    private func storageChain<T>(forKey key: String) -> Store<T> {
        if let store = stores[key] {
            if let castStore = store as? Store<T> {
                return castStore
            }
            fatalError("🧨🧨🧨 Cast failure. Cannot cast a " + String(describing: type(of: store)) + " to a Store<" + String(describing: T.self) + ">.")
        }
        fatalError("🧨🧨🧨 Unknown key: " + key)
    }
}
