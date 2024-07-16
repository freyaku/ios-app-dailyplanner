//
//  AboutViewController.swift
//  FIT3178-Assignment
//
//  Created by Ku Zhi Ning on 09/06/2023.
//

/**
View controller for about page

*/

import UIKit

class AboutViewController: UIViewController {
    
    
    @IBOutlet weak var aboutLabel: UILabel!
    
    
    @IBOutlet weak var attributionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        aboutLabel.text = "PlanWithMe App is a powerful and intuitive mobile application designed to help you organize your daily tasks and manage your time effectively. Whether you're a student, professional, or someone who wants to stay organized, PlanWithMe App is here to simplify your life."
        
        attributionLabel.text = "Weather data provided by OpenWeather. link: https://openweathermap.org/ "
        
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
