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

class TriggersTableController: NSObject, UITableViewDataSource {
    static let null: TriggersTableController = TriggersTableController.init()
    var tableView: UITableView = UITableView.init()
    var timestamps: [SchedulingTimestamp] = []
    var dateFormatter: DateFormatter = DateFormatter.init()
    
    override init() {
        super.init()
    }
    
    init(tableView: UITableView) {
        super.init()
        self.tableView = tableView;
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: String(describing: TriggersTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: TriggersTableViewCell.self))
        self.timestamps = SchedulingTimestampDao().findAll()
        self.dateFormatter.timeStyle = .short
        self.dateFormatter.dateStyle = .none
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index: Int = indexPath.row
        let schedulingTimestamp: SchedulingTimestamp = self.timestamps[index]
        let cell: TriggersTableViewCell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: TriggersTableViewCell.self)) as! TriggersTableViewCell
        var dateCmp: DateComponents = DateComponents.init()
        dateCmp.hour = Int(schedulingTimestamp.hour ?? "")
        dateCmp.minute = Int(schedulingTimestamp.minute ?? "")
        let date: Date = Calendar.autoupdatingCurrent.date(from: dateCmp)!
        let time: String = self.dateFormatter.string(from: date)
        cell.show(time: time)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.timestamps.count
    }
}
