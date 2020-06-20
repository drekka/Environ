//
//  Store.swift
//  locus
//
//  Created by Derek Clarkson on 19/5/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

import os

/// Provides methods for casting value types.
public protocol Castable {

    /**
     Perform a cast.

     - parameter value: The value to be cast.
     - parameter key: The key of the setting. Mostly used for error reporting.
     - parameter T: The type to cast the value to.
     - returns: The cast value.
     - throws: A fatal error if the cast cannot be made.
     */
    func cast<T>(_ value: Any, forKey key: String) -> T
}

public extension Castable {

    func cast<T>(_ value: Any, forKey key: String) -> T {
        if let castValue = value as? T {
            os_log("%@Resolving %@ -> %@", type: .debug, logPrefix, key, String(describing: value))
            return castValue
        }
        fatalError(fatalPrefix + "Unable to cast value for '" + key + "'")
    }
}
