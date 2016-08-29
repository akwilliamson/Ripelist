//
//  HomeViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 2/26/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit

class HomeViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.frame.size.width = self.view.frame.width + 4
        self.setAppearance(ofTabBar: self.tabBar)
        self.styleTabBarItems(forTabBar: self.tabBar)
    }
    
    private func setAppearance(ofTabBar tabBar: UITabBar) -> Void {
        tabBar.barTintColor = UIColor.forestColor()
        tabBar.tintColor = UIColor.whiteColor()
    }
    
    private func styleTabBarItems(forTabBar tabBar: UITabBar) {
        let tabBarItemSize = CGSize(width: tabBar.frame.width/4, height: tabBar.frame.height)
        tabBar.selectionIndicatorImage = UIImage.selectedImageWithColor(UIColor.goldColor(), size: tabBarItemSize)
        tabBar.frame.origin.x = -2
        
        if let tabBarIcons = tabBar.items as [UITabBarItem]? {
            tabBarIcons.forEach {
                if let tabBarImage = $0.image {
                    $0.image = tabBarImage.imageWithColor(UIColor.whiteColor()).imageWithRenderingMode(.AlwaysOriginal)
                }
            }
        }
    }
}
