//
//  ChainedStore.swift
//  Locus
//
//  Created by Derek Clarkson on 6/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

/**
 A store that can be chained with other stores to provide the a sequence of processes for storing and retrieving settings.

 All the methods and variables in Store are overridden to forward to this stores parent store.
 */
open class ChainedStore<V>: Store<V> {

    let parent: Store<V>

    public override var key: String {
        return parent.key
    }

    public override var value: V {
        return parent.value
    }

    /**
     Initializer that accepts the parent store.
     */
    public init(parent: Store<V>) {
        self.parent = parent
    }

    public override func update(defaultValue value: V) {
        parent.update(defaultValue: value)
    }

    public override func store(newValue value: V) {
        parent.store(newValue: value)
    }
}

