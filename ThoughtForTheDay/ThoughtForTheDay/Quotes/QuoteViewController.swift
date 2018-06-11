//
//  ViewController.swift
//  ThoughtForTheDay
//
//  Created by Martin on 5/26/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import UIKit

class QuoteViewController: UIViewController {
    let quoteDataProvider: QuoteDataProvider = QuoteDataProvider()
    var tableController: QuoteTableController?
    @IBOutlet var tableView: UITableView!
    
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//
//        super.init(coder: aDecoder)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableController = QuoteTableController.init(with: self.tableView)
        
        // https://gist.github.com/sooop/a2b110f8eebdf904d0664ed171bcd7a2
        
        var buffer: Data = String("TextOfUndisclosedPower").data(using: .utf8) ?? Data.init()
        print("\(buffer.startIndex), \(buffer.endIndex)")
        if let range: Range = buffer.range(of: String("U").data(using: .utf8) ?? Data.init(), options: [], in: buffer.startIndex..<buffer.endIndex) {
            print("found")
        }
    }
}
