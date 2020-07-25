//
//  JSONLoader.swift
//  Locus
//
//  Created by Derek Clarkson on 21/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

import os

/**
 Loads settings from a source and passes it to a mapper before updating Locus with new defaults.

Loaders make use of two other structs to load settings. A DataSource instaince which can asynchronously read data from any type of source and a mapper that then processes that data into a Dictionary of settings keys and default values to be set. It should noted here that loaders only set the default value of a setting. If there is an updated value in user defaults or some other storage area, that value will still be returned in preference to the default value.
 */
public struct Loader {

    private let source: DataSource
    private let mapper: Mapper

    // MARK: - Initializers

    /**
     Default initializer.

     - parameter source: A DataSource that returns settings as a Data instance.
     - parameter mapper: Is usually matched to the Data that the DataSource returns and knows how to convert it to a Dictionary of setting key value pairs.
     */
    public init(from source: DataSource, usingMapper mapper: Mapper)  {
        self.source = source
        self.mapper = mapper
    }

    // MARK: - Loader

    func load(into loadable: Loadable, completion: @escaping (Result<Void, Error>) -> Void) {

        os_log("🧩 Requesting data ...", type: .debug)
        source.read { result in
            do {
                switch result {
                case .success(let data):
                    os_log("🧩 Data retrieved, calling deserializer", type: .debug)
                    try mapper.map(data: data).forEach { key, value in
                        os_log("🧩     • %@ -> %@", type: .debug, key, String(describing: value))
                        loadable.update(key: key, withNewDefault: value)
                    }
                    completion(.success(()))

                case .failure(let error):
                    throw error
                }
            }
            catch let error {
                completion(.failure(error))
            }
        }
    }
}
