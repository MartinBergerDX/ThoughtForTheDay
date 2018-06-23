//
//  QuoteTableController.swift
//  ThoughtForTheDay
//
//  Created by Martin on 5/26/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import Foundation
import UIKit
import Services

class QuoteTableController: NSObject, UITableViewDataSource {
    let tableView: UITableView!
    var dataProvider: IndexedQuoteDataProviderProtocol
    
    init(with tableView: UITableView!, quoteDataProvider: IndexedQuoteDataProviderProtocol) {
        self.tableView = tableView
        self.dataProvider = quoteDataProvider
        super.init()
        setupTableView(tableView: tableView)
    }
    
    func setupTableView(tableView: UITableView!) {
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: String(describing: QuoteTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: QuoteTableViewCell.self))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: QuoteTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: QuoteTableViewCell.self)) as! QuoteTableViewCell
        cell.quoteLabel?.text = self.dataProvider.quote(atIndex: indexPath.row)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataProvider.count()
    }
    
}
