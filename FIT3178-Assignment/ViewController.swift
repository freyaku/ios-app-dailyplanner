//
//  ViewController.swift
//  FIT3178-Assignment
//
//  Created by Zhi Ku on 22/4/2023.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    


    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBOutlet weak var monthLabel: UILabel!
    
    var selectedDate = Date()
    var totalSquares = [Date] ()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setCellsView()
        setWeekView()
    }
    
    func setCellsView (){
        let width = (collectionView.frame.size.width - 2) / 8
        let height = (collectionView.frame.size.height - 2) / 8
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
        
    }
    
    func setWeekView(){
        totalSquares.removeAll()
        
        var current = CalendarHelper().sundayForDate(date: selectedDate)
        let nextSunday = CalendarHelper().addDays(date: current, days: 7)
        
        while(current < nextSunday){
            totalSquares.append(current)
            current = CalendarHelper().addDays(date: current, days: 1)
            
        }

        monthLabel.text = CalendarHelper().monthString(date: selectedDate) + " "
        + CalendarHelper().yearString(date: selectedDate)
        collectionView.reloadData()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CalendarCell
        
        let date = totalSquares[indexPath.item]
        cell.dayOfMonth.text = String(CalendarHelper().dayOfMonth(date: date))
        
        if (date == selectedDate){
            cell.backgroundColor = UIColor.systemGreen
        }
        else{
            cell.backgroundColor = UIColor.white
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedDate = totalSquares[indexPath.item]
        collectionView.reloadData()
    }
    
    @IBAction func previousWeek(_ sender: Any) {
        selectedDate = CalendarHelper().addDays(date: selectedDate, days: -7)
        setWeekView()
    }
    

    
    @IBAction func nextWeek(_ sender: Any) {
        selectedDate = CalendarHelper().addDays(date: selectedDate, days: 7)
        setWeekView()
    }
    
  
    
    override open var shouldAutorotate: Bool{
        return false
    }
    

}

