//
//  TriggersViewController.swift
//  ThoughtForTheDay
//
//  Created by Martin on 6/23/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

class TriggersViewController: UIViewController {
    var tableView: UITableView = UITableView.init()
    var tableController: TriggersTableController = TriggersTableController.null
    
    override func viewDidLoad() {
        super.viewDidLoad()
        installTableView()
        self.tableController = TriggersTableController.init(tableView: self.tableView)
    }
    
    fileprivate func installTableView() {
        self.view.addSubview(self.tableView)
        self.tableView.autoPinEdgesToSuperviewEdges()
    }
}
