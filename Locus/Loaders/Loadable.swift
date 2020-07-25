//
//  Registerable.swift
//  locus
//
//  Created by Derek Clarkson on 21/5/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

/**
 Loadable allows objects to receive updates to default values. It's only implemented on the `LocusContainer` so the container can be passed to a Loader.
 */
public protocol Loadable {

    /**
     Updates the `Loadable` with a new value for a key.

     - parameter key: The key of the setting.
     - parameter value: The new default value.
     */
    func update<V>(key: String, withNewDefault value: V)
}
