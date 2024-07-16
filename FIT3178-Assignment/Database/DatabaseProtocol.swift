//
//  DatabaseProtocol.swift
//  FIT3178-Assignment
//
//  Created by Zhi Ning Ku on 6/5/2023.
//

import Foundation

enum DatabaseChange {
    case add // Indicates an event has been added to the database
    case remove // Indicates an event has been removed from the database
    case update // Indicates an event has been updated in the database
}

enum ListenerType {
    case all // Indicates that the listener wants to be notified of all types of changes
}

// Protocol for database listeners
protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType { get set } // The type of listener
    func onTaskChange(change: DatabaseChange, event: [Event]) // Called when there is a change in the database
}

// Protocol for the database
protocol DatabaseProtocol: AnyObject {
    // Clean up resources.
    func cleanup()
    
    // Add a listener to the database
    func addListener(listener: DatabaseListener)
    
    // Remove a listener from the database
    func removeListener(listener: DatabaseListener)
    
    // Add an event to the database
    func addEvent(title: String, date: Date, startTime: Date, endTime: Date, location: String, notificationOnOff: Bool, isCompleted: Bool, notificationInterval: Date, category: Category) -> Event
    
    // Delete an event from the database
    func deleteEvent(event: Event)
    
    // Edit an event in the database
    func editEvent(event: Event, title: String, date: Date, startTime: Date, endTime: Date, location: String, notificationOnOff: Bool, isCompleted: Bool, notificationInterval: Date, category: Category) -> Event

}

