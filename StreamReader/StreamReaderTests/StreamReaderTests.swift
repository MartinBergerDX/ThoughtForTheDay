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
    
    func testReadFirstLine() {
        let line: String = self.streamReader.readLine()
        XCTAssertTrue(line == "Line 1")
    }
}
