//
//  StreamReaderTests.swift
//  StreamReaderTests
//
//  Created by Martin on 6/11/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import XCTest
@testable import StreamReader

class StreamReaderTests: XCTestCase {
    var streamReader: StreamReader = StreamReader.null
    var fileUrl: URL = URL.init(fileURLWithPath: "")
    
    override func setUp() {
        super.setUp()
        self.fileUrl = Bundle(for: type(of: self)).url(forResource: "TestText", withExtension: "txt") ?? URL.init(fileURLWithPath: "")
        self.streamReader = StreamReader(url: self.fileUrl)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCheckFileExistanceInBundle() {
        XCTAssertTrue(FileManager.default.fileExists(atPath: self.fileUrl.path))
    }
    
    func testStreamReaderInitializedSuccessfully() {
        XCTAssertTrue(self.streamReader.isValid())
    }

    func testReadChunkIfBufferEmpty() {
        var _: String = self.streamReader.readLine()
        XCTAssertTrue(self.streamReader.buffer.count > 0)
    }
    
    func testReadOneLine() {
        let line: String = self.streamReader.readLine()
        XCTAssertTrue(line == "Line 1")
    }
    
    func testReadTwoLines() {
        let line1: String = self.streamReader.readLine()
        XCTAssertTrue(line1 == "Line 1")
        let line2: String = self.streamReader.readLine()
        XCTAssertTrue(line2 == "Line 2")
    }
    
    func testReadAllLines() {
        let line1: String = self.streamReader.readLine()
        XCTAssertTrue(line1 == "Line 1")
        let line2: String = self.streamReader.readLine()
        XCTAssertTrue(line2 == "Line 2")
        let line3: String = self.streamReader.readLine()
        XCTAssertTrue(line3 == "Line 3")
        let line4: String = self.streamReader.readLine()
        XCTAssertTrue(line4 == "Line 4")
        let line5: String = self.streamReader.readLine()
        XCTAssertTrue(line5 == "Line 5 Long long long long long line")
        let line6: String = self.streamReader.readLine()
        XCTAssertTrue(line6 == "Line 6")
    }
    
    func testReadAllLinesWithSmallBuffer() {
        let streamReader: StreamReader = StreamReader.init(url: self.fileUrl, delimiter: "\n", chunkSize: 10, encoding: .utf8)
        let line1: String = streamReader.readLine()
        XCTAssertTrue(line1 == "Line 1")
        let line2: String = streamReader.readLine()
        XCTAssertTrue(line2 == "Line 2")
        let line3: String = streamReader.readLine()
        XCTAssertTrue(line3 == "Line 3")
        let line4: String = streamReader.readLine()
        XCTAssertTrue(line4 == "Line 4")
        let line5: String = streamReader.readLine()
        XCTAssertTrue(line5 == "Line 5 Long long long long long line")
        let line6: String = streamReader.readLine()
        XCTAssertTrue(line6 == "Line 6")
    }
}
