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
        setupNavigationItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableController.refreshTriggers()
    }
    
    fileprivate func setupNavigationItem() {
        let setup: UIViewControllerSetup = UIViewControllerSetup.init(with: self, target: self, selector: #selector(onAdd(sender:)))
        setup.selectedImageName = "icon_add_selected"
        setup.deselectedImageName = "icon_add_deselected"
        setup.title = "Trigger list"
        setup.setupNavigationBar()
    }
    
    fileprivate func installTableView() {
        self.view.addSubview(self.tableView)
        self.tableView.autoPinEdgesToSuperviewEdges()
    }
    
    @objc fileprivate func onAdd(sender: UIButton) {
        let selector = SelectorViewController.init()
        self.navigationController?.pushViewController(selector, animated: true)
    }
}
