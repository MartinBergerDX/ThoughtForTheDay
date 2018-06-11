//
//  File.swift
//  StreamReader
//
//  Created by Martin on 6/11/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import Foundation

protocol StreamReaderProtocol {
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
    var eof: Bool = false
    var endValue: String = ""
    
    init() {
        
    }

    init(url: URL, delimiter: String = "\n", chunkSize: Int = 4096, encoding: String.Encoding = .utf8) {
        if let fileHandle = try? FileHandle.init(forReadingFrom: url) {
            self.fileHandle = fileHandle
        }
        self.fileUrl = url
        self.bufferSize = chunkSize
        self.chunkSize = chunkSize
        self.buffer = Data.init(capacity: chunkSize)
        self.delimiterModel = delimiter.data(using: .utf8)!
    }
    
    func isValid() -> Bool {
        return self.fileHandle !== FileHandle.nullDevice
    }
    
    func readLine() -> String {
        if self.eof {
            return self.endValue
        }
        
        repeat {
            if let range: Range = self.buffer.range(of: self.delimiterModel, options: [], in: buffer.startIndex..<buffer.endIndex) {
                return ""
            } else {
                if readDataChunk() == false {
                    return self.endValue
                }
            }
        } while true
    }
    
    func readDataChunk() -> Bool {
        var newData: Data = self.fileHandle.readData(ofLength: self.chunkSize)
        self.eof = (newData.count == 0)
        buffer.append(newData)
        return self.eof == false
    }
}
