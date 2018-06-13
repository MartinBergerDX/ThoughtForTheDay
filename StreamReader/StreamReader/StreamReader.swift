//
//  File.swift
//  StreamReader
//
//  Created by Martin on 6/11/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import Foundation

public protocol StreamReaderProtocol {
    func isValid() -> Bool
    func readLine() -> String
    var eof: Bool { get }
}

public class StreamReader : StreamReaderProtocol {
    public static let null: StreamReader = StreamReader.init()
    var fileUrl: URL = URL.init(fileURLWithPath: "")
    var bufferSize: Int = 0
    var chunkSize: Int = 0
    var buffer: Data = Data.init()
    var delimiterModel: Data = Data()
    var fileHandle: FileHandle = FileHandle.nullDevice
    public var eof: Bool = false
    var endValue: String = ""
    var encoding: String.Encoding = .utf8
    
    init() {
        
    }

    public init(url: URL, delimiter: String = "\n", chunkSize: Int = 4096, encoding: String.Encoding = .utf8) {
        if let fileHandle = try? FileHandle.init(forReadingFrom: url) {
            self.fileHandle = fileHandle
        }
        self.fileUrl = url
        self.bufferSize = chunkSize
        self.chunkSize = chunkSize
        self.buffer = Data.init(capacity: chunkSize)
        self.delimiterModel = delimiter.data(using: encoding)!
        self.encoding = encoding
    }
    
    public func isValid() -> Bool {
        return self.fileHandle !== FileHandle.nullDevice
    }
    
    public func readLine() -> String {
        if self.eof {
            return self.endValue
        }
        
        repeat {
            let bufferRange: Range = buffer.startIndex ..< buffer.endIndex
            if let range: Range = self.buffer.range(of: self.delimiterModel, options: [], in: bufferRange) {
                return readLineFromBuffer(range: range)
            } else {
                if readDataChunk() == false {
                    return self.endValue
                }
            }
        } while true
    }
    
    func readLineFromBuffer(range: Range<Data.Index>) -> String {
        let lineRange: Range = self.buffer.startIndex ..< range.lowerBound
        let lineData: Data = self.buffer.subdata(in: lineRange)
        let line: String = String.init(data: lineData, encoding: self.encoding) ?? ""
        let clearRange: Range = self.buffer.startIndex ..< range.upperBound
        self.buffer.replaceSubrange(clearRange, with: [])
        return line
    }
    
    func readDataChunk() -> Bool {
        var newData: Data = self.fileHandle.readData(ofLength: self.chunkSize)
        self.eof = (newData.count == 0)
        buffer.append(newData)
        return self.eof == false
    }
}
