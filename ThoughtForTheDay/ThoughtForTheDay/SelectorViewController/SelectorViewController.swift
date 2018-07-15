//
//  SelectorViewController.swift
//  ThoughtForTheDay
//
//  Created by Martin on 7/5/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import Foundation
import UIKit
import Services

class SelectorViewController: UIViewController {
    fileprivate var timePicker: UIDatePicker = UIDatePicker.init(forAutoLayout: ())
    fileprivate var selectedTime: Date = Date.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        configure(timePicker: self.timePicker)
        addPickerSubview(self.timePicker, toView: self.view)
        setupNavigationItem()
    }
    
    fileprivate func addPickerSubview(_ picker: UIDatePicker, toView: UIView) {
        toView.addSubview(picker)
        picker.autoPinEdge(toSuperviewMargin: .top)
        picker.autoPinEdge(.left, to: .left, of: toView)
        picker.autoPinEdge(.right, to: .right, of: toView)
    }
    
    fileprivate func configure(timePicker picker: UIDatePicker) {
        picker.datePickerMode = .time
        picker.date = self.selectedTime
        picker.addTarget(self, action: #selector(onSelectedTime(sender:)), for: .valueChanged)
    }
    
    fileprivate func setupNavigationItem() {
        let setup: UIViewControllerSetup = UIViewControllerSetup.init(with: self, target: self, selector: #selector(onSave(sender:)))
        setup.selectedImageName = "icon_done_selected"
        setup.deselectedImageName = "icon_done_deselected"
        setup.title = "Select time"
        setup.setupNavigationBar()
    }
    
    @IBAction fileprivate func onSelectedTime(sender: UIDatePicker) {
        self.selectedTime = sender.date
    }
    
    @IBAction fileprivate func onSave(sender: UIButton) {
        let hour: String = readHourFromPicker()
        let minute: String = readMinuteFromPicker()
        let dao: SchedulingTimestampDao = SchedulingTimestampDao.init()
        if (dao.scheduledTimestampExists(with: hour, minute: minute)) {
            alertTimeAlreadySelected()
            return
        }
        let entity: SchedulingTimestamp = dao.insertNew()
        entity.hour = hour
        entity.minute = minute
        let _ = dao.saveToPersistentStore()
        ServiceRegistry.shared.notification.reschedule()
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func alertTimeAlreadySelected() {
        let alert: UIAlertController = UIAlertController.init(title: "Error", message: "This time already exists", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func readHourFromPicker() -> String {
        return String(Calendar.current.component(.hour, from: self.timePicker.date))
    }
    
    fileprivate func readMinuteFromPicker() -> String {
        return String(Calendar.current.component(.minute, from: self.timePicker.date))
    }
}
