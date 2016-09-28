//
//  NavigationVC.swift
//  Ripelist
//
//  Created by Aaron Williamson on 5/3/16.
//  Copyright © 2016 Aaron Williamson. All rights reserved.
//

import Foundation
import Apptentive

class NavigationVC: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance(ofNavBar: self.navigationBar)
        
        if #available(iOS 9.0, *) {
            UINavigationBar.appearance(whenContainedInInstancesOf: [ApptentiveNavigationController.self]).barTintColor = UIColor.forestColor()
        }
    }
    
    fileprivate func setAppearance(ofNavBar navBar: UINavigationBar) -> Void {
        navBar.barTintColor = UIColor.forestColor()
        navBar.tintColor = UIColor.white
        guard let fontSize = UIFont(name: "ArialRoundedMTBold", size: 25) else { return }
        navBar.titleTextAttributes = [NSFontAttributeName: fontSize, NSForegroundColorAttributeName: UIColor.white]
    }
}
