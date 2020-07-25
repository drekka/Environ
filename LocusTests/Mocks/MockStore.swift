//
//  MockStore.swift
//  locusTests
//
//  Created by Derek Clarkson on 28/5/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

@testable import Locus

class MockStore<V>: Store<V> {

    private var _value: V
    override var value: V {
        return _value
    }

    private var _key: String
    override var key: String {
        return _key
    }

    init(key: String, value: V) {
        _key = key
        _value = value
        super.init()
    }

    override func store(newValue value: V) {
       _value = value
    }

    override func update(defaultValue value: V) {
        _value = value
    }
}
