//
//  TabBarViewController.swift
//  FIT3178-Assignment
//
//  Created by Ku Zhi Ning on 24/04/2023.
//
/**
View controller responsible for initializing the tab bar image.

*/

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // initialize the tab bar
        viewControllers?[0].tabBarItem.image=UIImage(systemName: "cloud.fill")
        viewControllers?[1].tabBarItem.image=UIImage(systemName: "house.fill")
        viewControllers?[2].tabBarItem.image=UIImage(systemName: "chart.line.uptrend.xyaxis")
        selectedIndex = 1
    

    
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
