//
//  TriggersTableController.swift
//  ThoughtForTheDay
//
//  Created by Martin on 6/26/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import Foundation
import UIKit
import Services

class TriggersTableController: NSObject {
    static let null: TriggersTableController = TriggersTableController.init()
    var tableView: UITableView = UITableView.init()
    var dataProvider: TriggersDataProvider = TriggersDataProvider()
    
    override init() {
        super.init()
    }
    
    init(tableView: UITableView, dataProvider: TriggersDataProvider) {
        super.init()
        self.tableView = tableView;
        tableView.dataSource = self
        tableView.delegate = self
        self.dataProvider = dataProvider
        registerCells()
    }
    
    fileprivate func registerCells() {
        self.tableView.register(UINib.init(nibName: String(describing: TriggersTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: TriggersTableViewCell.self))
    }
    
    func refreshTriggers() {
        self.dataProvider.load()
        self.tableView.reloadData()
    }
}

extension TriggersTableController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index: Int = indexPath.row
        let quoteEvent: QuoteEvent = self.dataProvider.object(at: index)
        let cell: TriggersTableViewCell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: TriggersTableViewCell.self)) as! TriggersTableViewCell
        var dateCmp: DateComponents = DateComponents.init()
        dateCmp.hour = Int(quoteEvent.hour ?? "")
        dateCmp.minute = Int(quoteEvent.minute ?? "")
        let date: Date = Calendar.autoupdatingCurrent.date(from: dateCmp)!
        let time: String = DateUtils.shared.dateFormatter.string(from: date)
        cell.show(time: time)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataProvider.count()
    }
}

extension TriggersTableController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.dataProvider.setToCancel(indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
