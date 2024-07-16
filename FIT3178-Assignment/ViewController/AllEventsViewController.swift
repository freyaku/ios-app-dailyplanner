//
//  ViewController.swift
//  FIT3178-Assignment
//
//  Created by Zhi Ning Ku on 22/4/2023.
//

/**
View controller responsible for displaying all events. This class provides a user interface to view and manage a list of events.

The AllEventsViewController incorporates a search functionality that allows the user to search for events by name. It displays the event name, date and time.

The class supports various actions related to event management, such as creating new events, editing existing events, and deleting events. It provides an intuitive user interface for performing these actions, including interactive buttons and gestures.
Additionally, the AllEventsViewController allows users to search sort and filter events based on different category.

The view controller implements the necessary protocols for handling search bar interactions, table view delegates, and event management actions. It utilizes data models and data sources to store and retrieve event information, ensuring the user interface stays synchronized with the underlying data.

In addition to the above functionalities, the AllEventsViewController incorporates long press and drag gestures for recalculating events. By long pressing on an event, the user can initiate a drag action, allowing them to move the event to a different time. This interactive feature provides a convenient way for users to adjust their event schedule dynamically.

*/

import UIKit

class AllEventsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, DatabaseListener, UISearchResultsUpdating{
    
    
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var monthLabel: UILabel!
    
    // variables
    var selectedDate = Date()
    var totalSquares = [Date] ()
    var listenerType = ListenerType.all
    weak var databaseController: DatabaseProtocol?
    var allEvents: [Event] = []
    var filteredEvents: [Event] = []
    var selectedEvent: Event?
    var longPressGesture: UILongPressGestureRecognizer!
    var dragIndexPath: IndexPath?
    var dragSnapshot: UIView?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setCellsView()
        setWeekView()
        collectionView.delegate = self
        collectionView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        //create search controller
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search All Events"
        searchController.searchBar.scopeButtonTitles = ["Urgent", "Not Urgent"]
        
        navigationItem.searchController = searchController
        // This view controller decides how the search controller is presented
        definesPresentationContext = true
        filteredEvents = allEvents
        
        // Register custom table view cell
        tableView.register(EventTableViewCell.self, forCellReuseIdentifier: "taskCell")
        
        // Configure long press gesture
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        tableView.addGestureRecognizer(longPressGesture)
        
      
    }
    
    
    // The weekly calendar layout comes from https://www.youtube.com/watch?v=E-bFeJLsvW0
    
    // setting cells view
    func setCellsView (){
        let width = (collectionView.frame.size.width ) / 8
        let height = (collectionView.frame.size.height ) / 8
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
        
    }
    
    // setting week view
    func setWeekView() {
        // remove all squares to start new week
        totalSquares.removeAll()
        // find sunday of the week
        var current = CalendarHelper().sundayForEachWeek(date: selectedDate)
        let nextSunday = CalendarHelper().addDays(date: current, days: 7)
        
        // loop through all the days and append to the array
        while current < nextSunday {
            totalSquares.append(current)
            current = CalendarHelper().addDays(date: current, days: 1)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy" // Format to display the complete date
        let selectedDateString = dateFormatter.string(from: selectedDate)
        monthLabel.text = selectedDateString
        
        filteredEvents = allEvents.filter { event in
            return Calendar.current.isDate(event.date!, inSameDayAs: selectedDate)
        }
        
        collectionView.reloadData()
        tableView.reloadData()
    }
    
    // return count of collection cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DateCollectionViewCell
        
        // Retrieve the date corresponding to the current index
        let date = totalSquares[indexPath.item]
        
        // Set the day of the month label
        cell.dayOfMonth.text = String(CalendarHelper().dayOfMonth(date: date))
        
        // Customize the cell's background color based on the selection
        if (date == selectedDate) {
            cell.backgroundColor = UIColor.systemMint // Set selected date color
        } else {
            cell.backgroundColor = UIColor.white // Set default background color
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Retrieve the selected date based on the indexPath
        selectedDate = totalSquares[indexPath.item]
        
        // Update the week view based on the selected date
        setWeekView()
        
        // Reload the table view to display the updated data
        tableView.reloadData()
    }

    @IBAction func previousWeek(_ sender: Any) {
        // Subtract 7 days from the selected date to navigate to the previous week
        selectedDate = CalendarHelper().addDays(date: selectedDate, days: -7)
        
        // Update the week view based on the new selected date
        setWeekView()
        
        // Reload the table view to display the updated data
        tableView.reloadData()
        
        // Reload the collection view to update the visual representation of dates
        collectionView.reloadData()
    }

    @IBAction func nextWeek(_ sender: Any) {
        // Add 7 days to the selected date to navigate to the next week
        selectedDate = CalendarHelper().addDays(date: selectedDate, days: 7)
        
        // Update the week view based on the new selected date
        setWeekView()
        
        // Reload the table view to display the updated data
        tableView.reloadData()
        
        // Reload the collection view to update the visual representation of dates
        collectionView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Filter the events based on whether they occur on the selected date
        let filteredCount = filteredEvents.filter { Calendar.current.isDate($0.date!, inSameDayAs: selectedDate) }.count
        
        // Return the number of rows based on the filtered count
        return filteredCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable cell with the specified identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell") as! EventTableViewCell
        
        // Configure the cell's content
        var content = cell.defaultContentConfiguration()
        let event = filteredEvents[indexPath.row]
        content.text = event.title
        
        // Set the secondary text to display the start and end times if available
        if let startTime = event.startTime, let endTime = event.endTime {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            let startTimeString = dateFormatter.string(from: startTime)
            let endTimeString = dateFormatter.string(from: endTime)
            content.secondaryText = startTimeString + "-" + endTimeString
        }
        
        // Assign the configured content to the cell's content configuration
        cell.contentConfiguration = content
        
        // Set checkmark accessory for completed events, remove it for incomplete events
        if event.isCompleted {
            let checkmark = UIImage(systemName: "checkmark")
            let checkmarkImageView = UIImageView(image: checkmark)
            cell.accessoryView = checkmarkImageView
        } else {
            cell.accessoryView = nil
        }
        
        // Return the configured cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Retrieve the event associated with the selected row
        let event = filteredEvents[indexPath.row]
        
        // Delete the event from the database
        databaseController?.deleteEvent(event: event)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Retrieve the selected event
        selectedEvent = filteredEvents[indexPath.row]
        
        // Perform the segue to show event information
        self.performSegue(withIdentifier: "showEventInformation", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEventInformation" {
            if let destination = segue.destination as? EditEventViewController {
                // Pass the selected event to the destination view controller
                let indexPath = tableView.indexPathForSelectedRow!
                let event = filteredEvents[indexPath.row]
                destination.event = event
            }
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add listener to the database controller
        databaseController?.addListener(listener: self)
        
        // Reload data in the table view and collection view
        tableView.reloadData()
        collectionView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove listener from the database controller
        databaseController?.removeListener(listener: self)
    }

    func onTaskChange(change: DatabaseChange, event: [Event]) {
        // Update the allEvents array with the retrieved events
        allEvents = event
        
        // Sort the allEvents array based on start time
        allEvents.sort(by: { $0.startTime! < $1.startTime! })
        
        // Reload data in the table view and collection view
        tableView.reloadData()
        collectionView.reloadData()
        
        // Update search results for the search controller
        updateSearchResults(for: navigationItem.searchController!)
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }
        
        let selectedUniverse = searchController.searchBar.selectedScopeButtonIndex
        
        // Filter the events based on the search text, selected date, and scope button
        if searchText.count > 0 {
            filteredEvents = allEvents.filter { event in
                let isTitleMatch = event.title?.lowercased().contains(searchText) ?? false
                let isCategoryMatch = event.eventCategory.rawValue == selectedUniverse
                let isDateMatch = Calendar.current.isDate(event.date!, inSameDayAs: selectedDate)
                return isTitleMatch && isCategoryMatch && isDateMatch
            }
        } else {
            // Filter the events based on the selected date
            filteredEvents = allEvents.filter { Calendar.current.isDate($0.date!, inSameDayAs: selectedDate) }
        }
        
        // Reload data in the table view and collection view
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: tableView)
        
        switch gesture.state {
        case .began:
            // Check if the long press gesture is on a valid row
            if let indexPath = tableView.indexPathForRow(at: location) {
                dragIndexPath = indexPath
                
                // Create a snapshot view of the cell being dragged
                if let cell = tableView.cellForRow(at: indexPath) {
                    dragSnapshot = cell.snapshotView(afterScreenUpdates: true)
                    
                    if let snapshot = dragSnapshot {
                        snapshot.frame = cell.frame
                        tableView.addSubview(snapshot)
                        
                        // Hide the original cell and animate the snapshot view
                        cell.alpha = 0.0
                        cell.isHidden = true
                        
                        UIView.animate(withDuration: 0.25) {
                            snapshot.center = location
                            snapshot.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                            snapshot.alpha = 0.95
                        }
                    }
                }
            }
            
        case .changed:
            // Move the snapshot view along with the gesture
            guard let snapshot = dragSnapshot else {
                return
            }
            
            snapshot.center = location
            
            // Check if the gesture is within the table view bounds
            if tableView.bounds.contains(location) {
                // Check if the destination index path is different from the source index path
                if let destinationIndexPath = tableView.indexPathForRow(at: location),
                   let sourceIndexPath = dragIndexPath,
                   destinationIndexPath != sourceIndexPath {
                    
                    // Calculate and update the adjusted event times based on the drag operation
                    let newEvents = calculateAdjustedEventTimes(filteredEvents, movingIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
                    if newEvents != nil {
                        filteredEvents = newEvents!
                        
                        // Move the row within the table view
                        tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
                        
                        // Update the dragIndexPath to the new destination
                        dragIndexPath = destinationIndexPath
                    } else {
                        // There is a conflict in time, so return the cell to its original position
                        tableView.reloadData()
                        dragSnapshot?.removeFromSuperview()
                        tableView.cellForRow(at: sourceIndexPath)?.isHidden = false
                        dragSnapshot = nil
                        dragIndexPath = nil
                    }
                }
            }
            
        case .ended, .cancelled:
            // Handle the completion of the gesture
            if let snapshot = dragSnapshot, let dragIndexPath = dragIndexPath {
                // Animate the snapshot view to its final position and appearance
                UIView.animate(withDuration: 0.25, animations: {
                    snapshot.frame = self.tableView.rectForRow(at: dragIndexPath)
                    snapshot.transform = .identity
                    snapshot.alpha = 1.0
                }, completion: { _ in
                    // Show the original cell and remove the snapshot view
                    if let cell = self.tableView.cellForRow(at: dragIndexPath) {
                        cell.isHidden = false
                    }
                    
                    snapshot.removeFromSuperview()
                    
                    // Reset the dragIndexPath and dragSnapshot
                    self.dragIndexPath = nil
                    self.dragSnapshot = nil
                })
            }
            
        default:
            break
        }
    }

    func calculateAdjustedEventTimes(_ events: [Event], movingIndexPath: IndexPath, destinationIndexPath: IndexPath) -> [Event]? {
        var updatedEvents = events
        
        // Get the event being moved
        let movingEvent = updatedEvents[movingIndexPath.row]
        
        // Calculate the duration of the moving event
        let duration = movingEvent.endTime?.timeIntervalSince(movingEvent.startTime!) ?? 0
        
        var newStartTime: Date
        var newEndTime: Date
        
        // Check if the moving event is completed
        guard !movingEvent.isCompleted else {
            // If the event is already completed, disallow adjustments
            return nil
        }
        
        if destinationIndexPath.row < movingIndexPath.row {
            // Dragging upwards
            
            if destinationIndexPath.row == 0 {
                // Moving to the topmost position
                let startTime = events[0].startTime ?? Date()
                newStartTime = startTime.addingTimeInterval(-duration)
                newEndTime = newStartTime.addingTimeInterval(duration)
            } else {
                let previousEvent = events[destinationIndexPath.row - 1]
                let previousEndTime = previousEvent.endTime ?? Date()
                let nextEvent = events[destinationIndexPath.row]
                let nextStartTime = nextEvent.startTime ?? Date()
                
                // Calculate new start time as the midpoint between previous end time and next start time, adjusted for duration
                newStartTime = previousEndTime.addingTimeInterval((nextStartTime.timeIntervalSince(previousEndTime) - duration) / 2)
                newEndTime = newStartTime.addingTimeInterval(duration)
            }
        } else {
            // Dragging downwards
            
            if destinationIndexPath.row >= updatedEvents.count {
                // Moving to the bottommost position
                let lastEvent = events[events.count - 1]
                let endTime = lastEvent.endTime ?? Date()
                newEndTime = endTime.addingTimeInterval(duration)
                newStartTime = newEndTime.addingTimeInterval(-duration)
            } else {
                let previousEvent = events[destinationIndexPath.row]
                var nextEvent: Event?
                
                if destinationIndexPath.row + 1 < updatedEvents.count {
                    nextEvent = events[destinationIndexPath.row + 1]
                }
                
                let previousEndTime = previousEvent.endTime ?? Date()
                let nextStartTime = nextEvent?.startTime ?? Date()
                
                // Calculate new end time as the midpoint between previous end time and next start time, adjusted for duration
                newEndTime = previousEndTime.addingTimeInterval((nextStartTime.timeIntervalSince(previousEndTime) - duration) / 2)
                newStartTime = newEndTime.addingTimeInterval(-duration)
            }
        }
        
        // Check for conflicts with other events
        for (index, event) in updatedEvents.enumerated() {
            if event != movingEvent {
                if let startTime = event.startTime, let endTime = event.endTime {
                    if (newStartTime >= startTime && newStartTime < endTime) || (newEndTime > startTime && newEndTime <= endTime) {
                        // Conflict with another event, return nil to indicate failure
                        return nil
                    }
                }
            } else {
                // Update the start and end time of the moving event
                updatedEvents[index].startTime = newStartTime
                updatedEvents[index].endTime = newEndTime
            }
        }
        
        // Sort the updated events by start time
        updatedEvents.sort { $0.startTime ?? Date() < $1.startTime ?? Date() }
        
        return updatedEvents
    }
    
    
}
