//
//  UIViewController+NavigationBar.swift
//  ThoughtForTheDay
//
//  Created by Martin on 7/5/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import Foundation
import UIKit

class UIViewControllerSetup {
    var viewController: UIViewController
    var selectedImageName: String = ""
    var deselectedImageName: String = ""
    var title: String = ""
    var target: Any
    var selector: Selector
    
    init(with viewController: UIViewController, target: Any, selector: Selector) {
        self.viewController = viewController
        self.target = target
        self.selector = selector
    }
    
    func setupNavigationBar() {
        self.viewController.title = self.title
        
        let add: UIButton = UIButton.init(type: .custom)
        add.setImage(UIImage.init(named: self.deselectedImageName), for: .normal)
        add.setImage(UIImage.init(named: self.selectedImageName), for: .highlighted)
        add.widthAnchor.constraint(equalToConstant: 32).isActive = true
        add.heightAnchor.constraint(equalToConstant: 32).isActive = true
        add.addTarget(self.target, action: self.selector, for: .touchUpInside)
        
        let bar: UIBarButtonItem = UIBarButtonItem.init(customView: add)
        self.viewController.navigationItem.rightBarButtonItem = bar
    }
}
