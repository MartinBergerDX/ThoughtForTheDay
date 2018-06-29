//
//  TriggersTableController.swift
//  ThoughtForTheDay
//
//  Created by Martin on 6/26/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import Foundation
import UIKit

class TriggersTableController: NSObject, UITableViewDataSource {
    var tableView: UITableView = UITableView.init()
    
    init(tableView: UITableView) {
        super.init()
        self.tableView = tableView;
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return TriggersTableViewCell.init()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
}
