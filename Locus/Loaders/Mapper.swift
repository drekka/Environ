//
//  Mapper.swift
//  Locus
//
//  Created by Derek Clarkson on 17/7/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

import os

/**
Mappers are responsible for taking the raw `Data` that a `DataSource` generates, reading it and returning a `Dictionary` of settings.
 */
public struct Mapper {

    /**
     The signature of the closure that will do the mapping.

     - parameter data: The data read by the DataReader.
     - returns: A [String: Any] dictionary of settings.
     - throws: Can throw any error produced by the closure.
     */
    public typealias Mapping = (_ data: Data) throws -> [String: Any]

    private let map: Mapping

    /**
     Default initializer.

     - parameter map: A closure or function reference that will do the mapping.
     */
    public init(mapDataUsing map: @escaping Mapping) {
        self.map = map
    }

    func map(data: Data) throws -> [String: Any] {
        return try map(data)
    }
}

// MARK: - Pre-built Mappers

public extension Mapper {

    /**
     Decodes the data into a `Decodable` instance which is then passed to a closure to source the settng key value pairs from.

     - parameter using: The closure that maps the `Decodable` to the key value pairs.
     - parameter decodable: The `Decodable` instance deserialized from the data.
     - returns: A mapper that can map the data using the `Decodable` and closure.
     */
    static func jsonDecodable<D>(using: @escaping (_ decodable: D) throws -> [String: Any]) -> Mapper where D: Decodable {
        return Mapper { data in
            os_log("🧩 Deserializing data as a decodable %@", type: .debug, String(describing: D.self))
            let obj = try JSONDecoder().decode(D.self, from: data)
            return try using(obj)
        }
    }

    /**
     Deserializes the JSON in the data into a known Foundation type. Usually a `[String: Any]` or `[Any]` and passes it to the closure to source the settng key value pairs from.

     - parameter using: The closure that maps the foundation type.
     - parameter object: The foundation instance returned from the deserialization.
     - throws: Errors from the `JSONSerialization.jsonObject(with:)` function.
     - returns: A mapper that maps the data.
     */
    static func json(using: @escaping (_ object: Any) throws -> [String: Any]) -> Mapper {
        return Mapper { data in
            os_log("🧩 Deserializing JSON data", type: .debug)
            let obj = try JSONSerialization.jsonObject(with: data)
            return try using(obj)
        }
    }

    /**
     Convenience variation on `json(using:)` that assumes the data contains a valid JSON dictionary.

     The real purpose of this version of the function is to make the closure easier to define as it's already typed for a dictionary.

     - parameter using: The closure that maps the `Dictionary` to the key value pairs.
     - parameter dictionary: The dictionary returned from the deserialization.
     - throws: Errors from the `JSONSerialization.jsonObject(with:)` function.
     - returns: A mapper that maps the data.
     */
    static func jsonDictionary(using: @escaping (_ dictionary: [String: Any]) throws -> [String: Any]) -> Mapper {
        return self.json { object in
            os_log("🧩 Deserializing JSON data into a [String: Any] dictionary", type: .debug)
            if let dictionary = object as? [String: Any] {
                return try using(dictionary)
            }
            throw LocusError.unexpectedDeserializationResult
        }
    }

    /**
     Reads the data as plist file contents using a `PropertyListSerialization` instance.

     - parameter using: A closure that accepts the plist data and returns the settings key value pairs.
     - parameter plist: The deserialized plist data.
     - thowss: Errors from the `PropertyListSerialization.propertyList(from:options:format:)` function.
     - returns: A mapper that reads the property list data.
     */
    static func plist(using: @escaping (_ plist: Any) throws -> [String: Any]) -> Mapper {
        return Mapper { data in
            os_log("🧩 Deserializing plist data", type: .debug)
            return try using(PropertyListSerialization.propertyList(from: data, options: [], format: nil))
        }
    }
}

