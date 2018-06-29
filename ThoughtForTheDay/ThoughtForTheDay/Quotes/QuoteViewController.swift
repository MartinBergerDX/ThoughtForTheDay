//
//  ViewController.swift
//  ThoughtForTheDay
//
//  Created by Martin on 5/26/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import UIKit
import Services

class QuoteViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    let quoteDataProvider: IndexedQuoteDataProviderProtocol = QuoteDataProvider(textFileName: Constants.fileName)
    var tableController: QuoteTableController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableController = QuoteTableController.init(with: self.tableView, quoteDataProvider: self.quoteDataProvider)
        self.title = "Thought for the day"
    }
    
    @IBAction func onShowTriggers(sender: UIButton) {
        let triggers: TriggersViewController = TriggersViewController.init()
        self.navigationController?.pushViewController(triggers, animated: true)
    }
}
