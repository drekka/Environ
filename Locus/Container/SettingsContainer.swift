//
//  Resolvable.swift
//  locus
//
//  Created by Derek Clarkson on 19/5/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

/**
 Provides acess to settings.
 */
public protocol SettingsContainer {

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
     - parameter access: The access level of the setting. ie. whether it is writable, etc.
     - parameter default: The default value for the setting.
     */
    func register<T>(key: String, access: AccessLevel, default: T)

    /**
     Registers a setting with the container.

     This form takes a key that conforms to the `RawRepresentable` protocol. Normally this would be an enum of settings keys.

     - parameter key: The unque key used to identify the setting.
     - parameter access: The access level of the setting. ie. whether it is writable, etc.
     - parameter default: The default value for the setting.
     */
    func register<K, T>(key: K, access: AccessLevel, default: T) where K: RawRepresentable, K.RawValue == String

    /**
     Resolves a setting and returns the current value for it.

     - parameter key: The unque key used to identify the setting.
     - returns: The current value for the setting.
     */
    func resolve<T>(_ key: String) -> T

    /**
     Resolves a setting and returns the current value for it.

     This form takes a key that conforms to the `RawRepresentable` protocol. Normally this would be an enum of settings keys.

     - parameter key: The unque key used to identify the setting.
     - returns: The current value for the setting.
     */
    func resolve<K, T>(_ key: K) -> T where K: RawRepresentable, K.RawValue == String

    /**
     Update the current value of the setting. Note that the settings must have a access level of `.writable`, `.transient` or `.releaseLocked` (if this is a Debug build) for this to work.

     - parameter key: The unque key used to identify the setting.
     - parameter value: The new value of the setting.
     */
    func store<T>(key: String, value: T)

    /**
     Update the current value of the setting. Note that the settings must have a access level of `.writable`, `.transient` or `.releaseLocked` (if this is a Debug build) for this to work.

     This form takes a key that conforms to the `RawRepresentable` protocol. Normally this would be an enum of settings keys.

     - parameter key: The unque key used to identify the setting.
     - parameter value: The new value of the setting.
     */
    func store<K, T>(key: K, value: T) where K: RawRepresentable, K.RawValue == String

    /**
     Resets writable settings.

     This reset the setting back to it's default value by removing any stored values. Note that the default value will be whatever is loaded by the settings loaders. Reset only clears stored values for `.writable` and `.releaseLocked` settings.

     - parameter key: The key of the setting.
     */
    func reset(key: String)

    /**
     Resets writable settings.

     This reset the setting back to it's default value by removing any stored values. Note that the default value will be whatever is loaded by the settings loaders. Reset only clears stored values for `.writable` and `.releaseLocked` settings.

     This form takes a key that conforms to the `RawRepresentable` protocol. Normally this would be an enum of settings keys.

     - parameter key: The key of the setting.
     */
    func reset<K>(key: K) where K: RawRepresentable, K.RawValue == String

    /**
     Sets or returns the value for a setting.

     - parameter key: The key of the setting.
     - returns: The value for the setting.
     */
    subscript<T>(_ key:String) -> T { get set }

    /**
     Sets or returns the value for a setting.

     This form takes a key that conforms to the `RawRepresentable` protocol. Normally this would be an enum of settings keys.

     - parameter key: The key of the setting.
     - returns: The value for the setting.
     */
    subscript<K, T>(_ Key: K) -> T where K: RawRepresentable, K.RawValue == String { get set }
}

// MARK - Default implementations

public extension SettingsContainer {

    func register(_ registrars: (SettingsContainer) -> Void...) {
        registrars.forEach { $0(self) }
    }

    func register<T>(key: String, default defaultValue: T) {
        register(key: key, access: .readonly, default: defaultValue)
    }

    func register<K, T>(key: K, default defaultValue: T) where K: RawRepresentable, K.RawValue == String {
        register(key: key.rawValue, access: .readonly, default: defaultValue)
    }

    func register<K, T>(key: K, access: AccessLevel, default defaultValue: T) where K: RawRepresentable, K.RawValue == String {
        register(key: key.rawValue, access: access, default: defaultValue)
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

    subscript<T>(key: String) -> T {
        get { return resolve(key) }
        set { store(key: key, value: newValue) }
    }

    subscript<K, T>(key: K) -> T where K: RawRepresentable, K.RawValue == String {
        get { return resolve(key.rawValue) }
        set { store(key: key.rawValue, value: newValue) }
    }
}
