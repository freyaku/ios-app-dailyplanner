//
//  ProgressViewController.swift
//  FIT3178-Assignment
//
//  Created by Ku Zhi Ning on 24/04/2023.
//

/**
 This view controller displays the progress of events for a specific date. It includes an overall progress view, a distribution of urgent vs. non-urgent events, and a progress view for planned time.
*/

import UIKit

class ProgressViewController: UIViewController, DatabaseListener {
    
    
    var listenerType = ListenerType.all
    weak var databaseController: DatabaseProtocol?
    var allEvents: [Event] = []
    var filteredEvents: [Event] = []
    var currentDate = Date()
    
    // MARK: - IBOutlets

    @IBOutlet weak var progressStack: UIStackView!
    @IBOutlet weak var viewLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        currentDate = Date()
        let formattedDate = dateFormatter.string(from: currentDate)
        viewLabel.text = "Event Status (\(formattedDate))"
        
        // Add the three horizontal stack views to the main stack view
        progressStack.addArrangedSubview(overallProgressStackView())
        progressStack.addArrangedSubview(categoryDistributionStackView())
        progressStack.addArrangedSubview(createThirdStackView())

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Add self as a listener to the database controller
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove self as a listener from the database controller
        databaseController?.removeListener(listener: self)
    }
    
    // MARK: - DatabaseListener
    
    // Callback function called when there is a change in the database
    func onTaskChange(change: DatabaseChange, event: [Event]) {
        // Update the events array and filter the events for the current date
        allEvents = event
        filteredEvents = allEvents.filter { Calendar.current.isDate($0.date!, inSameDayAs: currentDate) }
        // Clear the existing stack views and create new ones
        progressStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        progressStack.addArrangedSubview(overallProgressStackView())
        progressStack.addArrangedSubview(categoryDistributionStackView())
        progressStack.addArrangedSubview(createThirdStackView())

    }
    
    // Create a horizontal stack view with default properties
    func createHorizontalStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }
    
    // Create the overall progress stack view
    func overallProgressStackView() -> UIStackView {
        let stackView = createHorizontalStackView()
        stackView.backgroundColor = .white
        
        // Create a vertical stack view to hold the title, progress bar, and legend
        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .center
        verticalStackView.distribution = .fill
        verticalStackView.spacing = 8
        
        // Create and configure the title label
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.black
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.text = "Overall Progress"
        verticalStackView.addArrangedSubview(titleLabel)
        
        // Create a container view for the progress view
        let progressContainerView = UIView()
        progressContainerView.backgroundColor = UIColor.clear
        
        // Create a background view for the progress shape
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.lightGray
        backgroundView.layer.cornerRadius = 10 // Adjust the corner radius to shape the progress view
        backgroundView.clipsToBounds = true
        
        // Create and configure the progress view
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = UIColor.systemCyan
        progressView.trackTintColor = UIColor.clear // Set the track color to clear to hide it
        
        let overallProgress = calculateOverallProgress()
        progressView.progress = overallProgress
        
        backgroundView.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        progressView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        progressView.topAnchor.constraint(equalTo: backgroundView.topAnchor).isActive = true
        progressView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        
        progressContainerView.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.centerXAnchor.constraint(equalTo: progressContainerView.centerXAnchor).isActive = true
        backgroundView.centerYAnchor.constraint(equalTo: progressContainerView.centerYAnchor).isActive = true
        backgroundView.widthAnchor.constraint(equalToConstant: 230).isActive = true // Set a fixed width for the progress bar
        backgroundView.heightAnchor.constraint(equalToConstant: 80).isActive = true // Set a fixed height for the progress bar
        
        verticalStackView.addArrangedSubview(progressContainerView)
        
        // Create a legend stack view to display the meaning of different colors
        let legendStackView = UIStackView()
        
        // Create colored indicator views for the legend
        let colors = [UIColor.systemCyan, UIColor.lightGray]
        let legendTitles = ["Completed  ", "Incomplete"]

        for (index, color) in colors.enumerated() {
            let legendItemStackView = UIStackView()
            legendItemStackView.axis = .horizontal
            legendItemStackView.alignment = .center
            legendItemStackView.distribution = .fill
            legendItemStackView.spacing = 8 // Adjust the spacing between the color indicator and the legend title

            let circleView = UIView()
            circleView.backgroundColor = color
            circleView.layer.cornerRadius = 4
            circleView.clipsToBounds = true
            circleView.widthAnchor.constraint(equalToConstant: 8).isActive = true // Adjust the width of the circle
            circleView.heightAnchor.constraint(equalToConstant: 8).isActive = true // Adjust the height of the circle

            let legendTitleLabel = UILabel()
            legendTitleLabel.text = legendTitles[index]
            legendTitleLabel.font = UIFont.systemFont(ofSize: 12)
            
            // Add the color indicator view and legend title label to the legend item stack view
            legendItemStackView.addArrangedSubview(circleView)
            legendItemStackView.addArrangedSubview(legendTitleLabel)

            // Add the legend item stack view to the legend stack view
            legendStackView.addArrangedSubview(legendItemStackView)
        }
        
        // Add the legend stack view to the vertical stack view
        verticalStackView.addArrangedSubview(legendStackView)
        
        // Add the vertical stack view to the main stack view
        stackView.addArrangedSubview(verticalStackView)
        
        return stackView
    }


    func calculateOverallProgress() -> Float {
        // Count the number of completed tasks
        let completedTaskCount = filteredEvents.filter { $0.isCompleted }.count
        
        // Count the total number of tasks
        let totalTaskCount = filteredEvents.count
        
        // Calculate the overall progress as a ratio of completed tasks to total tasks
        let overallProgress = totalTaskCount > 0 ? Float(completedTaskCount) / Float(totalTaskCount) : 0.0
        
        // Calculate the percentage of overall progress
        let percentage = Int(overallProgress * 100)
        
        // Update the progress label with the percentage
        if let progressLabel = progressStack.arrangedSubviews.first?.subviews.compactMap({ $0 as? UILabel }).first {
            progressLabel.text = "\(percentage)%"
        }
        
        // Return the overall progress as a float value
        return overallProgress
    }
    
    

    
    func categoryDistributionStackView() -> UIStackView {
        let stackView = createHorizontalStackView()
        stackView.backgroundColor = .white
        
        // Create a vertical stack view to hold the title, progress bar, and event count label
        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .center
        verticalStackView.distribution = .fill
        verticalStackView.spacing = 8
        
        // Create and configure the title label
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.black
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.text = "Distribution of Urgent vs. Non-Urgent Events"
        
        verticalStackView.addArrangedSubview(titleLabel)
        
        // Create a container view for the progress view
        let progressContainerView = UIView()
        progressContainerView.backgroundColor = UIColor.clear
        
        // Create a background view for the progress shape
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.lightGray
        backgroundView.layer.cornerRadius = 10 // Adjust the corner radius to shape the progress view
        backgroundView.clipsToBounds = true
        
        // Calculate the proportion of urgent and non-urgent tasks
        let urgentTasksCount = filteredEvents.filter { $0.category == 0 }.count
        let nonUrgentTasksCount = filteredEvents.filter { $0.category == 1 }.count
        let totalTasksCount = urgentTasksCount + nonUrgentTasksCount
        
        // Create and configure the progress view
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = UIColor.red
        progressView.trackTintColor = UIColor.clear // Set the track color to clear to hide it
        
        if totalTasksCount > 0 {
            let proportion = Float(urgentTasksCount) / Float(totalTasksCount)
            progressView.progress = proportion
        } else {
            progressView.progress = 0.0
        }
        
        backgroundView.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        progressView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        progressView.topAnchor.constraint(equalTo: backgroundView.topAnchor).isActive = true
        progressView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        
        progressContainerView.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.centerXAnchor.constraint(equalTo: progressContainerView.centerXAnchor).isActive = true
        backgroundView.centerYAnchor.constraint(equalTo: progressContainerView.centerYAnchor).isActive = true
        backgroundView.widthAnchor.constraint(equalToConstant: 230).isActive = true // Set a fixed width for the progress bar
        backgroundView.heightAnchor.constraint(equalToConstant: 80).isActive = true // Set a fixed height for the progress bar
        
        verticalStackView.addArrangedSubview(progressContainerView)
        
        // Create a legend stack view to display the meaning of different colors
        let legendStackView = UIStackView()
        
        // Create colored indicator views for the legend
        let colors = [UIColor.red, UIColor.lightGray]
        let legendTitles = ["Urgent  ", "Non-Urgent"]

        for (index, color) in colors.enumerated() {
            let legendItemStackView = UIStackView()
            legendItemStackView.axis = .horizontal
            legendItemStackView.alignment = .center
            legendItemStackView.distribution = .fill
            legendItemStackView.spacing = 8 // Adjust the spacing between the color indicator and the legend title

            let circleView = UIView()
            circleView.backgroundColor = color
            circleView.layer.cornerRadius = 4
            circleView.clipsToBounds = true
            circleView.widthAnchor.constraint(equalToConstant: 8).isActive = true // Adjust the width of the circle
            circleView.heightAnchor.constraint(equalToConstant: 8).isActive = true // Adjust the height of the circle

            let legendTitleLabel = UILabel()
            legendTitleLabel.text = legendTitles[index]
            legendTitleLabel.font = UIFont.systemFont(ofSize: 12)

            legendItemStackView.addArrangedSubview(circleView)
            legendItemStackView.addArrangedSubview(legendTitleLabel)

            legendStackView.addArrangedSubview(legendItemStackView)
        }
        
        verticalStackView.addArrangedSubview(legendStackView)
        
        stackView.addArrangedSubview(verticalStackView)
        
        return stackView
    }

    
    func createThirdStackView() -> UIStackView {
        let stackView = createHorizontalStackView()
        stackView.backgroundColor = .white
        
        // Create a vertical stack view to hold the title, progress bar
        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .center
        verticalStackView.distribution = .fill
        verticalStackView.spacing = 8
        
        // Create and configure the title label
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.black
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.text = "Planned Time"
        
        verticalStackView.addArrangedSubview(titleLabel)
        
        // Create a container view for the progress view
        let progressContainerView = UIView()
        progressContainerView.backgroundColor = UIColor.clear
        
        // Create a background view for the progress shape
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.lightGray
        backgroundView.layer.cornerRadius = 10 // Adjust the corner radius to shape the progress view
        backgroundView.clipsToBounds = true
        
        // Create and configure the progress view
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = UIColor.systemBlue
        progressView.trackTintColor = UIColor.clear // Set the track color to clear to hide it
        
        let plannedTime = calculatePlannedHours()
        let progress = Float(plannedTime.hours * 60 + plannedTime.minutes) / (24.0 * 60.0)
        
        progressView.progress = progress
        
        backgroundView.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        progressView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        progressView.topAnchor.constraint(equalTo: backgroundView.topAnchor).isActive = true
        progressView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        
        progressContainerView.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.centerXAnchor.constraint(equalTo: progressContainerView.centerXAnchor).isActive = true
        backgroundView.centerYAnchor.constraint(equalTo: progressContainerView.centerYAnchor).isActive = true
        backgroundView.widthAnchor.constraint(equalToConstant: 230).isActive = true // Set a fixed width for the progress bar
        backgroundView.heightAnchor.constraint(equalToConstant: 80).isActive = true // Set a fixed height for the progress bar
        
        verticalStackView.addArrangedSubview(progressContainerView)
        
        // Create and configure the time count label
        let timeCountLabel = UILabel()
        timeCountLabel.textColor = UIColor.black
        timeCountLabel.textAlignment = .center
        timeCountLabel.font = UIFont.systemFont(ofSize: 14)
        timeCountLabel.text = "Planned Time: \(plannedTime.hours) hours \(plannedTime.minutes) minutes"
        
        verticalStackView.addArrangedSubview(timeCountLabel)
        
        stackView.addArrangedSubview(verticalStackView)
        
        return stackView
    }

    // Calculates the total planned hours
    func calculatePlannedHours() -> (hours: Int, minutes: Int) {
        var plannedHours = 0 // Variable to store the total planned hours
        var plannedMinutes = 0 // Variable to store the total planned minutes
        
        for event in filteredEvents { // Iterate through each event in the filteredEvents array
            if let startTime = event.startTime, let endTime = event.endTime { // Check if both start time and end time are available for the event
                let calendar = Calendar.current // Get the current calendar
                let components = calendar.dateComponents([.hour, .minute], from: startTime, to: endTime) // Calculate the time difference between start time and end time
                
                if let hours = components.hour { // Check if the hour component is available
                    plannedHours += hours // Add the hours to the total planned hours
                }
                
                if let minutes = components.minute { // Check if the minute component is available
                    plannedMinutes += minutes // Add the minutes to the total planned minutes
                    if plannedMinutes >= 60 { // If the total planned minutes exceed 60
                        plannedHours += plannedMinutes / 60 // Add the excess minutes as hours
                        plannedMinutes %= 60 // Set the remaining minutes after converting to hours
                    }
                }
            }
        }
        
        return (hours: plannedHours, minutes: plannedMinutes) // Return the calculated total planned hours and minutes as a tuple
    }
    

}
