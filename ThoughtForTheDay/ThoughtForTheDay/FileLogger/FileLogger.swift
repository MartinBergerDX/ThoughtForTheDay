//
//  FileLogger.swift
//  ThoughtForTheDay
//
//  Created by Martin on 6/20/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import Foundation

class FileLogger: TextOutputStream {
    
    private init() {
        
    }
    
    func write(_ string: String) {
        let fm = FileManager.default
        let log = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("log.txt")
        if let handle = try? FileHandle(forWritingTo: log) {
            handle.seekToEndOfFile()
            handle.write(string.data(using: .utf8)!)
            handle.closeFile()
        } else {
            try? string.data(using: .utf8)?.write(to: log)
        }
    }
    
    static var logger = FileLogger()
}
