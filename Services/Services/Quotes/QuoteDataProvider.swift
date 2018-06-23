//
//  QuoteDataProvider.swift
//  ThoughtForTheDay
//
//  Created by Martin on 5/26/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import Foundation
import StreamReader

public protocol QuoteDataProviderProtocol {
    func count() -> Int
    func allQuotes() -> [String]
}

public protocol IndexedQuoteDataProviderProtocol: QuoteDataProviderProtocol {
    func quote(atIndex: Int) -> String
}

public protocol RandomQuoteDataProviderProtocol: QuoteDataProviderProtocol {
    func popRandomQuote() -> String
}

public class QuoteDataProvider: QuoteDataProviderProtocol {
    static let null: QuoteDataProvider = QuoteDataProvider.init()
    var quoteStreamReader: StreamReaderProtocol = TDStreamReader.null
    var fileUrl: URL = URL.init(fileURLWithPath: "")
    var quotes: [String] = []
    
    init() {
        
    }
    
    public init(textFileName: String) {
        self.fileUrl = Bundle(for: type(of: self)).url(forResource: textFileName, withExtension: "txt") ?? URL.init(fileURLWithPath: "")
        self.quoteStreamReader = TDStreamReader.init(url: self.fileUrl)
        loadQuotes()
    }
    
    fileprivate func loadQuotes() {
        self.quotes = allQuotes()
        print("Quotes loaded from text file. [\(self.quotes.count)]")
    }
    
    public func count() -> Int {
        return self.quotes.count
    }
    
    public func allQuotes() -> [String] {
        var quotes: [String] = []
        while self.quoteStreamReader.eof != true {
            let quote: String = self.quoteStreamReader.readLine()
            if quote.count > 0 {
                quotes.append(quote)
            }
        }
        self.quoteStreamReader.reset()
        return quotes
    }
}

extension QuoteDataProvider: IndexedQuoteDataProviderProtocol {
    public func quote(atIndex: Int) -> String {
        if (self.quotes.count == 0) {
            return ""
        }
        return self.quotes[atIndex]
    }
}

extension QuoteDataProvider: RandomQuoteDataProviderProtocol {
    public func popRandomQuote() -> String {
        if (self.quotes.count == 0) {
            loadQuotes()
        }
        let index: Int = Int(arc4random_uniform(UInt32(self.quotes.count)))
        let quote: String = self.quotes[index]
        self.quotes.remove(at: index)
        return quote
    }
}
