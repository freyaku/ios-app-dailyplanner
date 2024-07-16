//
//  CoreDataController.swift
//  FIT3178-Assignment
//
//  Created by Zhi Ku on 6/5/2023.
//

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
 
    var listeners = MulticastDelegate<DatabaseListener>() // Delegate listeners for database changes
    var persistentContainer: NSPersistentContainer // The Core Data persistent container
    var allEventsFetchedResultsController: NSFetchedResultsController<Event>? // Fetched results controller for all events
    
    // Initialize the CoreDataController
    override init() {
        persistentContainer = NSPersistentContainer(name: "Assignment-DataModel") // Initialize the persistent container with the DataModel name
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data Stack with error: \(error)") // If there's an error, terminate the app
            }
        }
        super.init()
    }
    
    // Clean up resources by saving changes to the Core Data stack
    func cleanup() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save changes to Core Data with error: \(error)") // If there's an error saving changes, terminate the app
            }
        }
    }
    
    // Add a listener to the database
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .all {
            listener.onTaskChange(change: .update, event: fetchAllEvents()) // Notify the listener with all existing events
        }
    }
    
    // Remove a listener from the database
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    // Add an event to the database
    func addEvent(title: String, date: Date, startTime: Date, endTime: Date, location: String, notificationOnOff: Bool, isCompleted: Bool, notificationInterval: Date, category: Category) -> Event {
        let event = NSEntityDescription.insertNewObject(forEntityName: "Event", into: persistentContainer.viewContext) as! Event
        event.title = title
        event.date = date
        event.startTime = startTime
        event.endTime = endTime
        event.location = location
        event.notificationOnOff = notificationOnOff
        event.isCompleted = isCompleted
        event.notificationInterval = notificationInterval
        event.eventCategory = category
        
        return event
    }
    
    // Delete an event from the database
    func deleteEvent(event: Event) {
        persistentContainer.viewContext.delete(event)
    }
    
    // Edit an event in the database
    func editEvent(event: Event, title: String, date: Date, startTime: Date, endTime: Date, location: String, notificationOnOff: Bool, isCompleted: Bool, notificationInterval: Date, category: Category) -> Event {
        event.title = title
        event.date = date
        event.startTime = startTime
        event.endTime = endTime
        event.location = location
        event.notificationOnOff = notificationOnOff
        event.isCompleted = isCompleted
        event.notificationInterval = notificationInterval
        event.eventCategory = category
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("Failed to save changes to event: \(error.localizedDescription)")
        }
        
        return event
    }
    
    // Fetch all events from the database
    func fetchAllEvents() -> [Event] {
        if allEventsFetchedResultsController == nil {
            let request: NSFetchRequest<Event> = Event.fetchRequest()
            let titleSortDescriptor = NSSortDescriptor(key: "title", ascending: true)
            request.sortDescriptors = [titleSortDescriptor]
            
            allEventsFetchedResultsController = NSFetchedResultsController<Event>(fetchRequest: request, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            // Set this class as the results delegate
            allEventsFetchedResultsController?.delegate = self
            
            do {
                try allEventsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        
        if let events = allEventsFetchedResultsController?.fetchedObjects {
            return events
        }
        
        return [Event]()
    }
    
    // NSFetchedResultsControllerDelegate method called when there is a change in the fetched results
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allEventsFetchedResultsController {
            listeners.invoke() { listener in
                if listener.listenerType == .all {
                    listener.onTaskChange(change: .update, event: fetchAllEvents()) // Notify the listener with updated events
                }
            }
        }
    }
}
