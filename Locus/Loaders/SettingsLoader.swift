//
//  SettingsLoader.swift
//  locus
//
//  Created by Derek Clarkson on 19/5/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

public protocol SettingsLoader {
    func load(into: SettingsLoadable, completion: @escaping () -> Void)
}
