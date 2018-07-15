//
//  MockRandomQuoteDataProvider.swift
//  ThoughtForTheDayTests
//
//  Created by Martin on 6/15/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import UIKit
@testable import Services

class MockRandomQuoteDataProvider: NSObject, RandomQuoteDataProviderProtocol {
    var quotes: [String] = []
    
    override init() {
        super.init()
        self.quotes = allQuotes()
    }
    
    func count() -> Int {
        return 1000
    }
    
    func allQuotes() -> [String] {
        var quotes: [String] = []
        for i in 0 ..< count() {
            quotes.append(String.init(format: "Quote %zd", i))
        }
        self.quotes = quotes
        return quotes
    }
    
    func pop() -> String {
        let index: Int = Int(arc4random_uniform(UInt32(self.quotes.count)))
        let quote = self.quotes[index]
        self.quotes.remove(at: index)
        return quote
    }
    
    func push(quote: String) {
        self.quotes.append(quote)
    }
}
