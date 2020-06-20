//
//  Registerable.swift
//  locus
//
//  Created by Derek Clarkson on 21/5/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//


public protocol SettingsLoadable {
    func update<V>(key: String, defaultValue value: V)
}
