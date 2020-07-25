//
//  LocusError.swift
//  locus
//
//  Created by Derek Clarkson on 18/5/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

/// Locus specific errors.
enum LocusError: Error {

    // Thrown when there is a problem casting a setting value.
    case cast

    ///Thrown when there is a url for a file or something that won't resolve.
    case invalidUrl(URL)

    /// Thrown if requested to load a file from a path that does not exist.
    case fileDoesNotExist(String)

    /// Thrown when remotely retrieving a config file.
    case networkError(HTTPURLResponse)

    /// Thrown when the deserialization process resulted in a type that cannot be passed to the updater.
    case unexpectedDeserializationResult

}
