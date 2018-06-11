//
//  QuoteTableController.swift
//  ThoughtForTheDay
//
//  Created by Martin on 5/26/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import Foundation
import UIKit

class QuoteTableController: NSObject, UITableViewDataSource {
    let tableView: UITableView!
    
    init(with tableView: UITableView!) {
        self.tableView = tableView
        super.init()
        setupTableView(tableView: tableView)
    }
    
    func setupTableView(tableView: UITableView!) {
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: String(describing: QuoteTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: QuoteTableViewCell.self))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: QuoteTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: QuoteTableViewCell.self)) as! QuoteTableViewCell
        cell.quoteLabel?.text = "ABC"
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
}
