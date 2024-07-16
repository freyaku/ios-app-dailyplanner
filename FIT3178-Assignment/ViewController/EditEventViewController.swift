//
//  EditEventViewController.swift
//  FIT3178-Assignment
//
//  Created by Zhi Ning Ku on 23/4/2023.
//

import UIKit
import UserNotifications

/**
 View controller responsible for editing or adding an event. This class provides the user interface for creating a new event or modifying an existing event. It allows the user to enter details such as title, date, start time, end time, location, notification settings, and event category.

 The class contains various methods and properties related to event management, including adding, deleting, and editing events. It communicates with the underlying database or data source to persist event data.
*/

class EditEventViewController: UIViewController{

    
    var event: Event?
    var allEvents : [Event] = []
    var success : Bool = false
    var selectedDate: Date?
    weak var databaseController: DatabaseProtocol?
    

    // MARK: - Outlets
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dateTextField: UIDatePicker!
    @IBOutlet weak var eventStartTimeTextField: UIDatePicker!
    @IBOutlet weak var eventEndTimeTextField: UIDatePicker!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var timeIntervalPicker: UIDatePicker!
    @IBOutlet weak var completedSwitch: UISwitch!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var eventCategorySegmentedControl: UISegmentedControl!
    

 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Populate the UI with event details if editing an existing event
        if let event = event {
            titleTextField.text = event.title
            dateTextField.date = event.date!
            eventStartTimeTextField.date = event.startTime!
            eventEndTimeTextField.date = event.endTime!
            locationTextField.text = event.location
            notificationSwitch.isOn = event.notificationOnOff
            timeIntervalPicker.date = event.notificationInterval!
            completedSwitch.isOn = event.isCompleted
            eventCategorySegmentedControl.selectedSegmentIndex = Int(event.category)
        }
        
        // Set the title label based on whether it's editing or adding an event
        if let _ = event {
            titleLabel.text = "Edit Event"
        } else {
            titleLabel.text = "Add Event"
        }
    
        
        // Request permission for user notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { (granted, error) in
            if granted {
                print("Permission granted!")
            } else {
                print("Permission was not granted!")
            }
        }
    
    }
    // MARK: - Outlets

    @IBAction func saveEventAction(_ sender: Any) {
        // Check if the title and location fields have values
        guard let title = titleTextField.text, let location = locationTextField.text else {
            return
        }

        let date = dateTextField.date
        let eventStartTime = eventStartTimeTextField.date
        let eventEndTime = eventEndTimeTextField.date
        let notificationOnOff = notificationSwitch.isOn
        let notificationInterval = timeIntervalPicker.date
        let isCompleted = completedSwitch.isOn
        let eventCategory = Category(rawValue: Int32(eventCategorySegmentedControl.selectedSegmentIndex))

        // Edit event
        if let event = self.event {
            // Edit existing event
            // Check if the required fields are empty
            if title == "" || location == "" {
                self.success = false
                displayMessage(title: "Error", message: "Empty field")
            } else if eventEndTime < eventStartTime {
                // Check if the end time is earlier than the start time
                self.success = false
                displayMessage(title: "Error", message: "The event end time should be later than the start time.")
            } else {
                // Update the event in the database
                databaseController?.editEvent(event: event, title: title, date: date, startTime: eventStartTime, endTime: eventEndTime, location: location, notificationOnOff: notificationOnOff, isCompleted: isCompleted, notificationInterval: notificationInterval, category: eventCategory!)

                self.success = true
                displayMessage(title: "Successful", message: "Event edited successfully")

                if notificationSwitch.isOn {
                    // Schedule a notification if the notification switch is on
                    let selectedTimeInterval = timeIntervalPicker.countDownDuration
                    scheduleNotification(for: event, countDownDuration: selectedTimeInterval)
                }
            }
        }

        // Add event
        else {
            // Add a new event
            // Check if the required fields are empty
            if title == "" || location == "" {
                self.success = false
                displayMessage(title: "Error", message: "Empty field")
            } else if eventEndTime < eventStartTime {
                // Check if the end time is earlier than the start time
                self.success = false
                displayMessage(title: "Error", message: "The event end time should be later than the start time.")
            } else {
                // Add the event to the database
                let newEvent = databaseController?.addEvent(title: title, date: date, startTime: eventStartTime, endTime: eventEndTime, location: location, notificationOnOff: notificationOnOff, isCompleted: isCompleted, notificationInterval: notificationInterval, category: eventCategory!)

                self.success = true
                displayMessage(title: "Successful", message: "Event added successfully")

                if notificationSwitch.isOn {
                    // Schedule a notification if the notification switch is on
                    let selectedTimeInterval = timeIntervalPicker.countDownDuration
                    scheduleNotification(for: newEvent, countDownDuration: selectedTimeInterval)
                }
            }
        }
    }
    
    
    func scheduleNotification(for event: Event?, countDownDuration: TimeInterval) {
        // Check if event and its properties exist
        guard let event = event, let startTime = event.startTime, let eventTitle = event.title else {
            return
        }
        
        // Calculate the notification date (1 minute before the start time)
        let notificationDate = startTime.addingTimeInterval(-countDownDuration)
        
        // Create the notification content
        let content = UNMutableNotificationContent()
        content.title = "Event Reminder"
        
        // Calculate the time difference between the current date and the start time
        let timeDifference = Calendar.current.dateComponents([.minute, .hour], from: Date(), to: startTime)
        var formattedTimeRemaining = ""
        
        // Format the time remaining based on the hours difference
        if let hours = timeDifference.hour, hours > 0 {
            formattedTimeRemaining += "\(hours) hour"
            if hours > 1 {
                formattedTimeRemaining += "s"
            }
        }
        
        // Format the time remaining based on the minutes difference
        if let minutes = timeDifference.minute, minutes > 0 {
            if !formattedTimeRemaining.isEmpty {
                formattedTimeRemaining += " "
            }
            formattedTimeRemaining += "\(minutes) minute"
            if minutes > 1 {
                formattedTimeRemaining += "s"
            }
        }
        
        // If no time difference, set the default message
        if formattedTimeRemaining.isEmpty {
            formattedTimeRemaining = "Less than a minute"
        }
        
        // Set the notification body
        content.body = "Your event '\(eventTitle)' is starting soon! \(formattedTimeRemaining) left"
        content.sound = UNNotificationSound.default
        
        // Create a UNCalendarNotificationTrigger with the trigger date components
        // Setting repeats to false means the notification will only be triggered once
        let triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
        
        // Create a UNNotificationRequest with a unique identifier, content, and trigger
        let request = UNNotificationRequest(identifier: "EventReminder_\(event.id)", content: content, trigger: trigger)
        
        // Add the request to the UNUserNotificationCenter
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }


    
    func displayMessage(title: String, message: String) {
        // Check if success is true
        if self.success == true {
            // Create an alert controller with the provided title and message
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            // Create a dismiss action that pops the view controller from the navigation stack
            let dismissAction = UIAlertAction(title: "Dismiss", style: .default) { [weak self] (_) in
                // Navigate back to the event details view
                self?.navigationController?.popViewController(animated: true)
            }
            
            // Add the dismiss action to the alert controller
            alertController.addAction(dismissAction)
            
            // Present the alert controller
            present(alertController, animated: true, completion: nil)
        } else {
            // Create an alert controller with the provided title and message
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            // Create a dismiss action without any additional behavior
            let dismissAction = UIAlertAction(title: "Dismiss", style: .default)
            
            // Add the dismiss action to the alert controller
            alertController.addAction(dismissAction)
            
            // Present the alert controller
            present(alertController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func viewWeatherButton(_ sender: Any) {
        // Perform segue to show the weather view
        performSegue(withIdentifier: "showWeatherSegue", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Check if the segue identifier matches the "showWeatherSegue"
        if segue.identifier == "showWeatherSegue" {
            // Check if the destination view controller is of type WeatherViewController
            if let destinationViewController = segue.destination as? WeatherViewController {
                // Pass the location text from the locationTextField to the WeatherViewController
                destinationViewController.location = locationTextField.text
            }
        }
    }
    


}
