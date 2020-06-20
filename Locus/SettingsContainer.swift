//
//  Resolvable.swift
//  locus
//
//  Created by Derek Clarkson on 19/5/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

/**
 Manages a set of settings for an application.
 */
public protocol SettingsContainer: SettingsSubscriptable {

    /**
     True by default. Auto-registers preferences found in the app's `Root.plist` and any child panes with the user defaults system.

     When on, executes the `UserDefaultsRegistrar` to scan the plists in the settings bundle and register any defaults found there. By default the keys are validated against the list of
     registered settings key and a fatal thrown if any are not found. This functionality is automatically triggered the first time any setting is accessed.
     */
    var registerAppSettings: Bool { get set }

    /// Override which allows settings plist files to be located in a bundle other than the main bundle.
    var appSettingsBundle: Bundle { get set }

    /// True by default. If a user default is found by the `UserDefaultsRegistrar` that has not been registered, then a `fatalError()` will be thrown.
    var validateAppSettingsKeys: Bool { get set }
    
    /**
     Registers settings with the container using one or more closures containing the register calls.

     Note that in addition to closures you can also pass function references as long as the function accepts a single argument of `SettingContainer`.

     - parameter using: A list of closures to execute.
     - parameter container: The container to register the settings with.
     */
    func register(_ using: (_ container: SettingsContainer) -> Void...)

    /**
     Registers a setting with the container.

     - parameter key: The unque key used to identify the setting.
     - parameter scope: The scope of the setting. ie. whether it is writable, etc.
     - parameter defaultValue: The default value for the setting.
     */
    func register<T>(key: String, scope: Scope, defaultValue: T)

    /**
     Registers a setting with the container.

     This form takes a key that conforms to the RawRepresentable protocol. Normally this would be an enum of settings keys.

     - parameter key: The unque key used to identify the setting.
     - parameter scope: The scope of the setting. ie. whether it is writable, etc.
     - parameter defaultValue: The default value for the setting.
     */
    func register<K, T>(key: K, scope: Scope, defaultValue: T) where K: RawRepresentable, K.RawValue == String

    /**
     Loads setting values from the passed loaders.
     */
    func load(fromLoaders loaders: SettingsLoader..., completion: @escaping () -> Void)

    /**
     Resolves a setting and returns the current value for it.

     - parameter key: The unque key used to identify the setting.
     - returns: The current value for the setting.
     */
    func resolve<T>(_ key: String) -> T

    /**
     Resolves a setting and returns the current value for it.

     This form takes a key that conforms to the RawRepresentable protocol. Normally this would be an enum of settings keys.

     - parameter key: The unque key used to identify the setting.
     - returns: The current value for the setting.
     */
    func resolve<K, T>(_ key: K) -> T where K: RawRepresentable, K.RawValue == String

    /**
     Update the current value of the setting. Note that the settings must have a scope of .writable, .transient or .releaseLocked (if this is a Debug build) for this to work.

     - parameter key: The unque key used to identify the setting.
     - parameter value: The new value of the setting.
     */
    func store<T>(key: String, value: T)

    /**
     Update the current value of the setting. Note that the settings must have a scope of .writable, .transient or .releaseLocked (if this is a Debug build) for this to work.

     This form takes a key that conforms to the RawRepresentable protocol. Normally this would be an enum of settings keys.

     - parameter key: The unque key used to identify the setting.
     - parameter value: The new value of the setting.
     */
    func store<K, T>(key: K, value: T) where K: RawRepresentable, K.RawValue == String

    /**
     Resets writable settings.

     This reset the setting back to it's default value by removing any stored values. Note that the default value will be whatever is loaded by the settings loaders. Reset only clears stored values for .writable and .releaseLocked settings.

     - parameter key: The key of the setting.
     */
    func reset(key: String)

    /**
     Resets writable settings.

     This reset the setting back to it's default value by removing any stored values. Note that the default value will be whatever is loaded by the settings loaders. Reset only clears stored values for .writable and .releaseLocked settings.

     This form takes a key that conforms to the RawRepresentable protocol. Normally this would be an enum of settings keys.

     - parameter key: The key of the setting.
     */
    func reset<K>(key: K) where K: RawRepresentable, K.RawValue == String
}

// MARK - Default implementations

public extension SettingsContainer {

    func register<T>(key: String, defaultValue: T) {
        register(key: key, scope: .readonly, defaultValue: defaultValue)
    }

    func register<K, T>(key: K, defaultValue: T) where K: RawRepresentable, K.RawValue == String {
        register(key: key.rawValue, scope: .readonly, defaultValue: defaultValue)
    }

    func register<K, T>(key: K, scope: Scope, defaultValue: T) where K: RawRepresentable, K.RawValue == String {
        register(key: key.rawValue, scope: scope, defaultValue: defaultValue)
    }

    func resolve<K, T>(_ key: K) -> T where K: RawRepresentable, K.RawValue == String {
        resolve(key.rawValue)
    }

    func store<K, T>(key: K, value: T) where K: RawRepresentable, K.RawValue == String {
        store(key: key.rawValue, value: value)
    }

    func reset<K>(key: K) where K: RawRepresentable, K.RawValue == String {
        reset(key: key.rawValue)
    }
}

// MARK: - SettingsSubscriptable

public extension SettingsContainer {

    subscript<T>(key: String) -> T {
        get { return resolve(key) }
        set { store(key: key, value: newValue) }
    }

    subscript<K, T>(key: K) -> T where K: RawRepresentable, K.RawValue == String {
        get { return resolve(key.rawValue) }
        set { store(key: key.rawValue, value: newValue) }
    }
}

