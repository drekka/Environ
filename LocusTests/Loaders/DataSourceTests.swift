//
//  JSONLoaderTests.swift
//  LocusTests
//
//  Created by Derek Clarkson on 21/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

import XCTest
@testable import Locus
import Nimble
import Swifter

struct TestX: Decodable {
    let abc: Int
}
let testJSONObject = ["abc": 5]
let testJSON = "{\"abc\":5}"
let testJSONURL = URL(string: "http://localhost:8080/good")!
let testBadJSONURL = URL(string: "http://localhost:8080/bad")!
let testEmptyPayloadURL = URL(string: "http://localhost:8080/empty")!

class DataSourceTests: XCTestCase {

    func testReadsData() {
        let sourceData = Data()
        runTest(dataSource:  DataSource { $0(.success(sourceData)) }) { data in
            expect(data) === sourceData
        } failureValidation: { fail("Unexpected error \($0)") }
    }
}

class DataSourceExtensionTests: XCTestCase {

    static var server: HttpServer!

    static override func setUp() {
        super.setUp()
        server = HttpServer()
        server["/good"] = { _ in .ok(.json(testJSONObject)) }
        try! server.start()
    }

    static override func tearDown() {
        server.stop()
        super.tearDown()
    }

    func testDataSource() {
        let sourceData = Data()
        runTest(dataSource: .dataSource(sourceData)) { data in
            expect(data) === sourceData
        } failureValidation: { fail("Unexpected error \($0)") }
    }

    func testURL() throws {
        runTest(dataSource: .url(testJSONURL)) { data in
            let json = String(data:data, encoding: .utf8)!.sansWhitespace
            expect(json) == testJSON
        } failureValidation: { fail("Unexpected error \($0)") }
    }

    func testRequest() throws {
        runTest(dataSource: .request(URLRequest(url: testJSONURL))) { data in
            let json = String(data:data, encoding: .utf8)!.sansWhitespace
            expect(json) == testJSON
        } failureValidation: { fail("Unexpected error \($0)") }
    }

    func testRequestWhenServerRejects() throws {
        runTest(dataSource: .request(URLRequest(url: testBadJSONURL))) { data in
            fail("Should not return success")
        } failureValidation: { error in

            guard case LocusError.networkError(let response) = error else {
                fail("Unexpected error \(error)")
                return
            }
            expect(response.statusCode) == 404
        }
    }

    func testRequestWithInvalidURL() throws {
        let request = URLRequest(url: URL(string: "file://XTestX.json")!)
        runTest(dataSource: .request(request)) { data in
            fail("Should have thrown an error")
        } failureValidation: { error in
            expect(error.localizedDescription) == "file is directory"
        }
    }
}

// MARK: - Test support

extension StringProtocol where Self: RangeReplaceableCollection {
    var sansWhitespace: Self {
        filter { !$0.isWhitespace }
    }
}

fileprivate func runTest(file: String = #file, line: UInt = #line,
                         dataSource: DataSource,
                         successValidation: @escaping (Data) -> Void,
                         failureValidation: @escaping (Error) -> Void) {

    var gotResult = false
    dataSource.read { result in

        gotResult = true

        switch result {

        case .success(let data):
            successValidation(data)

        case .failure(let error):
            failureValidation(error)
        }
    }

    expect(gotResult, file: file, line: line).toEventually(beTrue(), description: "Didn't get result from data source as expected")
}
