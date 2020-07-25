//
//  LoadableContainer.swift
//  Locus
//
//  Created by Derek Clarkson on 25/7/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

/**
 Features which define a settings container.
 */
public protocol Container: Loadable {

    /**
     True by default. Auto-registers preferences found in the app's `Root.plist` and any child panes with the user defaults system.

     When true executes the `UserDefaultsRegistrar` the next time a setting is resolved, then is turned off.
     The registrar scans the plists in the settings bundle and register any defaults it finds there. The keys are validated against the list of
     registered settings key and a fatal thrown if any are not found.
     */
    var registerAppPreferences: Bool { get set }

    /// Override which allows settings plist files to be located in a bundle other than the main bundle.
    var appSettingsBundle: Bundle { get set }

    /// True by default. If a user default is found in the application's preferences that has not been registered, then a `fatalError()` will be thrown. Otherwise it is ignored.
    var validateAppSettingsKeys: Bool { get set }

    /**
     Loads setting values from the passed loaders.
     */
    func load(fromLoaders loaders: Loader..., completion: @escaping (_ result: Result<Void, Error>) -> Void)
}
