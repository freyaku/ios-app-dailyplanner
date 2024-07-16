//
//  Event+CoreDataProperties.swift
//  FIT3178-Assignment
//
//  Created by Zhi Ku on 4/5/2023.
//
//

import Foundation
import CoreData


enum Category: Int32{
    case urgent = 0
    case notUrgent = 1
}


var eventsList = [Event]()
extension Event {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event")
    }

    @NSManaged public var title: String?
    @NSManaged public var location: String?
    @NSManaged public var date: Date?
    @NSManaged public var startTime: Date?
    @NSManaged public var endTime: Date?
    @NSManaged public var category: Int32
    @NSManaged public var notificationOnOff: Bool
    @NSManaged public var isCompleted: Bool
    @NSManaged public var notificationInterval: Date?
    

}

extension Event : Identifiable {

}

extension Event{
    var eventCategory: Category{
        get{
            return Category(rawValue: self.category)!
        }
        set{
            self.category = newValue.rawValue
        }
    }
}


