//
//  TriggersTableViewCell.swift
//  ThoughtForTheDay
//
//  Created by Martin on 6/26/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import Foundation
import UIKit

class TriggersTableViewCell: UITableViewCell {
    @IBOutlet fileprivate var timeLabel: UILabel!
    
    func show(time: String) {
        self.timeLabel.text = time
    }
}
