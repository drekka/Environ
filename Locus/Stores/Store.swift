//
//  Store.swift
//  Locus
//
//  Created by Derek Clarkson on 30/5/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

/**
 Base type for all settings stores.

 This type is used for refering to stores and therefore defines the common properties and functions that a store provides.
 */
open class Store<V> {

    /// Returns the key that identifies the setting.
    open var key: String {
        fatalError(fatalPrefix + "Key property must be overridden.")
    }

    /// Returns the current value of the setting.
    open var value: V {
        fatalError(fatalPrefix + "Value property for key '" + key + "' must be overridden.")
    }

    /**
     Sets the current value of the setting.

     Settings that are not updatable will trigger a fatal error.

     - parameter value: The new value for the setting.
     */
    open func store(newValue value: V) {
        fatalError(fatalPrefix + "Key " + key + " is not storable.")
    }

    /**
     Updates the default value of a setings.

     This differs from the store function in that the default value for a setting can always be updated. This function is mostly used by settings loaders to update values from config file and urls.

     - parameter value: The new default value for the setting.
     */
    open func update(withDefaultValue value: V) {
        fatalError(fatalPrefix + "Key " + key + " is not updateable.")
    }

    /**
     Resets stored values for this setting.
     */
    open func reset() {
        fatalError(fatalPrefix + "Key " + key + " is not reset.")
    }
}
