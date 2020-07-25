//
//  DataSource.swift
//  Locus
//
//  Created by Derek Clarkson on 17/7/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

import os

/**
 DataSources are using by the Loader class to read data containing settings and defaults.

 DataSources are always part of a pair, a data source and a mapper with the data source reading the data and the mapper turning it into a `Dictionary` of settings keys and default values.
 */
public struct DataSource {

    /**
     A closure that will accept the source's results.

     - parameter result: The result of reading the data source.
     */
    public typealias Completion = (_ result: Result<Data, Error>) -> Void

    /**
     The closure that will read the data.

     - parameter completion: The completion to call when the data has been read.
     */
    public typealias DataReader = (_ completion: @escaping Completion) -> Void

    private let readData: DataReader

    /**
     Default initializer.

     - parameter readData: A closure that reads the source of read and then calls a passed completion.
     */
    public init(readDataUsing readData: @escaping DataReader) {
        self.readData = readData
    }

    func read(withCompletion completion: @escaping Completion) {
        readData(completion)
    }
}

// MARK: - Pre-built data sources

public extension DataSource {

    /**
     Provides an already established `Data` instance as the source of settings.

     - parameter data: The data to return.
     - returns: A data source that returns the data.
     */
    static func dataSource(_ data: Data) -> DataSource {
        return DataSource { $0(.success(data)) }
    }

    /**
     Creates a `DataSource` that reads data from a URL.

     - parameter url: The `URL` to read the data from.
     - parameter session: A `URLSession` to use to execute the request for data. Defaults to a ephemeral session.
     - returns: A data source set to read the data from the `URL`.
     */
    static func url(_ url: URL, session: URLSession = URLSession(configuration: .ephemeral)) -> DataSource {
        return DataSource { completion in
            let request = URLRequest(url: url)
            DataSource.request(request, session: session).read(withCompletion: completion)
        }
    }

    /**
     Creates a `DataSource` that reads data from a `URLRequest`.

     - parameter request: The `URLRequest` that defines where we'll read the data from.
     - parameter session: A `URLSession` to use to execute the request for data. Defaults to a ephemeral session.
     - returns: A data source set to read the data.
     */
    static func request(_ request: URLRequest, session: URLSession = URLSession(configuration: .ephemeral)) -> DataSource {
        return DataSource { completion in

            let session = URLSession(configuration: .ephemeral)
            os_log("🧩 Loading settings from url: %@", type: .debug, request.url?.absoluteString ?? "Invalid URL")
            let task = session.dataTask(with: request) { data, response, error in

                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                    completion(.failure(LocusError.networkError(response)))
                    return
                }

                guard let data = data else {
                    completion(.failure(LocusError.fileDoesNotExist(request.url?.absoluteString ?? "No valid URL")))
                    return
                }

                completion(.success(data))
            }
            task.resume()
        }
    }

    /**
     Creates a `DataSource` that reads the contents of a local file.

     - parameter file: The path to the file to be read.
     - returns: A data source that returns the contents of the file.
     */
    static func file(_ file: String) -> DataSource {
        return DataSource { completion in
            os_log("🧩 Loading settings from file: %@", type: .debug, file)
            guard let data = FileManager.default.contents(atPath: file) else {
                completion(.failure(LocusError.fileDoesNotExist(file)))
                return
            }
            completion(.success(data))
        }
    }

    /**
     Creates a `DataSource` that reads the contents of a file stored in a bundle.

     - parameter file: The name of the file to be read.
     - parameter bundle: The `Bundle` where the file is stored.
     - returns: A data source that returns the contents of the file.
     */
    static func file(_ file: String, inBundle bundle: Bundle) -> DataSource {
        return DataSource { completion in
            os_log("🧩 Creating loader with file path: %@, in bundle: %@", type: .debug, file, String(describing: bundle))
            guard let url = bundle.url(forResource: file, withExtension: nil) else {
                completion(.failure(LocusError.fileDoesNotExist(file)))
                return
            }
            DataSource.url(url).read(withCompletion: completion)
        }
    }
}
