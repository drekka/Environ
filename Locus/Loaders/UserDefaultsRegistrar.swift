//
//  UserDefaultsRegistrar.swift
//  Locus
//
//  Created by Derek Clarkson on 13/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

import UIKit
import os

typealias PlistPreference = (file: String, key: String, value: Any)

struct UserDefaultsRegistrar {

    @discardableResult
    func register(bundle: Bundle = Bundle.main,
                  settingsBundleName: String = "Settings",
                  rootPlistName: String = "Root",
                  using: (PlistPreference) -> PlistPreference? = { $0 }) -> [String: Any] {

        guard let settingsUrl = bundle.url(forResource: settingsBundleName, withExtension: "bundle"),
            let settingsBundle = Bundle(url: settingsUrl) else {
                return [:]
        }

        os_log("%@Registering preferences from %@.plist in %@.bundle...", type: .debug, logPrefix, rootPlistName, settingsBundleName)
        let preferences = appPreferences(fromPlist: rootPlistName, inBundle: settingsBundle, using: using)
        let settings = Dictionary<String, Any>(uniqueKeysWithValues: preferences.map { ($0.key, $0.value) })
        UserDefaults.standard.register(defaults: settings)

        os_log("%@Registered preferences:", type: .debug, logPrefix)
        preferences.sorted { $0.key < $1.key }.forEach { os_log("%@    • %@.plist, %@: %@", type: .debug, logPrefix, $0.file, $0.key, String(describing: $0.value)) }

        return settings
    }

    private func appPreferences(fromPlist plist: String, inBundle bundle: Bundle, using: (PlistPreference) -> PlistPreference?) -> [PlistPreference] {

        guard let plistUrl = bundle.url(forResource: plist, withExtension: "plist"),
            let data = try? Data(contentsOf: plistUrl),
            let pl = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let preferences = pl["PreferenceSpecifiers"] as? [[String: Any]] else {
            return []
        }

        return preferences.reduce(into: [PlistPreference]()) { result, preference in

            // Recurse into child panes.
            if preference["Type"] as? String == "PSChildPaneSpecifier", let file = preference["File"] as? String {
                os_log("%@Found child pane %@ with preferences", type: .debug, logPrefix, file)
                result.append(contentsOf: appPreferences(fromPlist: file, inBundle: bundle, using: using))
                return
            }

            // Add the default if present.
            if let key = preference["Key"] as? String,
                let defaultValue = preference["DefaultValue"],
                let finalPreference = using((file: plist, key: key, value: defaultValue)) {

                // Check for duplicates
                if let duplicate = result.first(where: { $0.key == finalPreference.key }) {
                    fatalError(fatalPrefix + "Found duplicate key '" + finalPreference.key + "' in plists " + plist + ".plist and " + duplicate.file + ".plist")
                }

                result.append(finalPreference)
            }
        }
    }
}
