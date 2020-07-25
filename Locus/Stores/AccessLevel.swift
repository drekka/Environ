//
//  Metadata.swift
//  locus
//
//  Created by Derek Clarkson on 19/5/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

public enum AccessLevel {

    /// The setting is readonly and cannot be changed.
    case readonly

    /// The setting is transient in that it can be changed, but new values are not saved to perminant storage.
    case transient

    /// The setting can be updated. New values are stored so that when the app is restarted, the nwew value is returned.
    case writable

    /// Special case where the value can be updated in Debug builds but is readonly in release builds. Most useful for settings that need to be changed for test environments.
    case releaseLocked
}
