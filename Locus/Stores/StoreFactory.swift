//
//  StoreFactory.swift
//  Locus
//
//  Created by Derek Clarkson on 30/5/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

/**
 Defines a factory that is called to create a store for a setting.
 */
public protocol StoreFactory {
    /**
     called to create a store for a setting with the passed details.

     Settings are managed via a chain of stores, each with a parent which it defers to when necessary. StoreFactory instances are used to create the stores for a specific store.

     - parameter key: The key of the setting.
     - parameter access: The requested access level for the setting.
     - parameter parent: The parent store.
     - returns: A new store set with the parent, or the parent if this factory decides not to create a new store.
     */
    func createStoreForSetting<V>(withKey key: String, access: AccessLevel, parent: Store<V>) -> Store<V>
}
