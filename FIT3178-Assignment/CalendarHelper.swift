//
//  CalendarHelper.swift
//  FIT3178-Assignment
//
//  Created by Zhi Ning Ku on 22/4/2023.
//

import Foundation

class CalendarHelper{
    let calendar = Calendar.current
    
    // Return the month display string for the given date
    func monthDisplay(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: date)
    }
    
    // Return the year display string for the given date
    func yearDisplay(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: date)
    }
    
    // Return the day of the month for the given date
    func dayOfMonth(date: Date) -> Int {
        let components = calendar.dateComponents([.day], from: date)
        return components.day!
    }
    
    // Add the number of days to the given date and return the resulting date
    func addDays(date: Date, days: Int) -> Date {
        return calendar.date(byAdding: .day, value: days, to: date)!
    }
    
    // Get the date of the Sunday for the week of the given date
    func sundayForEachWeek(date: Date) -> Date {
        var current = date
        let oneWeekAgo = addDays(date: current, days: -7)
        while (current > oneWeekAgo) {
            let currentWeekDay = calendar.dateComponents([.weekday], from: current).weekday
            if (currentWeekDay == 1) {
                return current
            }
            current = addDays(date: current, days: -1)
        }
        return current
    }
}
