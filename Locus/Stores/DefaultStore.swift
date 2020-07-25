//
//  DefaultStore.swift
//  Locus
//
//  Created by Derek Clarkson on 6/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

/// Not publically accessible. This store is alway the final store in the chain of stores for a setting.
class DefaultStore<V>: Store<V> {

    private var settingKey: String
    override var key: String {
        settingKey
    }

    private var defaultValue: V
    override var value: V {
        return defaultValue
    }

    init(key: String, value: V) {
        self.settingKey = key
        self.defaultValue = value
    }

    override func update(defaultValue value: V) {
        defaultValue = value
    }
}

