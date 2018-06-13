//
//  QuoteDataProvider.swift
//  ThoughtForTheDay
//
//  Created by Martin on 5/26/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import Foundation
import StreamReader

class QuoteDataProvider {

    var quoteStreamReader: StreamReaderProtocol = StreamReader.null
    var fileUrl: URL = URL.init(fileURLWithPath: "")
    var quotes: [String] = []
    
    init() {
        self.fileUrl = Bundle(for: type(of: self)).url(forResource: "Quotes", withExtension: "txt") ?? URL.init(fileURLWithPath: "")
        self.quoteStreamReader = StreamReader.init(url: self.fileUrl)
        loadQuotes()
    }
    
    fileprivate func loadQuotes() {
        self.quotes = allQuotes()
        print("Quotes loaded from text file.")
    }
    
    internal func popRandomQuote() -> String {
        if (self.quotes.count == 0) {
            loadQuotes()
        }
        let index: Int = Int(arc4random_uniform(UInt32(self.quotes.count)))
        let quote: String = self.quotes[index]
        self.quotes.remove(at: index)
        return quote
    }
    
    internal func quote(atIndex: Int) -> String {
        return self.quotes[atIndex]
    }
    
    internal func count() -> Int {
        return self.quotes.count
    }
    
    internal func allQuotes() -> [String] {
        var quotes: [String] = []
        while self.quoteStreamReader.eof != true {
            let quote: String = self.quoteStreamReader.readLine()
            if quote.count > 0 {
                quotes.append(quote)
            }
        }
        return quotes
    }
}
