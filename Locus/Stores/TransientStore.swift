//
//  TransientStore.swift
//  Locus
//
//  Created by Derek Clarkson on 2/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

/**
 Transient stores are used when a setting is registered with a .transient access level.

 Transient stores track updated values for a setting, but do not store it perminantly. So the next time the app is loaded, the transient value will be reset to the setting's default value. Transient settings are most useful for things where you want something to occur only once each time the app is started.
 */
class TransientStore<V>: ChainedStore<V> {

    private var transient: V?

    override var value: V {
        if let transient = transient {
            return transient
        }
        return parent.value
    }

    override func store(newValue value: V) {
        transient = value
    }

    override func reset() {
        transient = nil
    }
}
