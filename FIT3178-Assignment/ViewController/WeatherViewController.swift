//
//  WeatherViewController.swift
//  FIT3178-Assignment
//
//  Created by Ku Zhi Ning on 24/04/2023.
//

/**
 View controller responsible for displaying weather information for a specific location. This class provides a user interface to search for weather data by location or retrieve the weather data based on the user's current location.

 The `WeatherViewController` incorporates a search functionality that allows the user to enter a location and fetch the corresponding weather information. It displays the location name, temperature, weather description, minimum and maximum temperatures, wind speed, and feels like temperature.

 The class also handles location updates using the `CLLocationManager` to fetch weather data for the user's current location. It prompts the user for location access authorization and uses reverse geocoding to obtain the city name based on the user's coordinates.

 The view controller implements the `UISearchBarDelegate` and `CLLocationManagerDelegate` protocols to handle search bar interactions and location updates, respectively. 
*/

import UIKit
import CoreLocation

class WeatherViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate {
    
    // MARK: - Outlets
    
    // Outlets for UI elements
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var weatherIconImage: UIImageView!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    
    
    // MARK: - Properties
    
    // Property to hold the location string
    var location: String?
    // Location manager to handle location updates
    let locationManager = CLLocationManager()
    // Search controller for location search functionality
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Search Controller Configuration
        
        // Set the delegate for the search bar
        searchController.searchBar.delegate = self
        // Configure search controller appearance
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search (Location, Country Code)"
        searchController.searchBar.showsCancelButton = false
        
        // Assign the search controller to the navigation item
        navigationItem.searchController = searchController
        // Ensure the search bar is always visible.
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // MARK: Location Manager Configuration
        
        // Request location access authorization
        locationManager.delegate = self
        // Set the desired accuracy level for location updates
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        // Request location access authorization
        locationManager.requestWhenInUseAuthorization()
        
        // MARK: Tap Gesture Configuration
        
        // Create tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideSearch))

        // Add tap gesture recognizer to the view
        view.addGestureRecognizer(tapGesture)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Call locationManagerDidChangeAuthorization to trigger authorization request
        locationManagerDidChangeAuthorization(locationManager)
    }
    
    // MARK: - Location Manager Delegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            // If a location is already available, search weather for that location
            if let location = location {
                searchWeather(location: location)
            } else {
                // Start updating the user's location
                locationManager.startUpdatingLocation()
            }
            
        case .denied, .restricted:
            // Display an alert to the user asking for permission to access location
            let alertController = UIAlertController(title: "Location Access Required", message: "Please grant permission to access your location.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
                // Open the Settings app to allow the user to grant permission
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            }))
            present(alertController, animated: true, completion: nil)
            
        case .notDetermined:
            // Authorization not determined yet, no action required at the moment
            break
            
        @unknown default:
            // Handle any future authorization status cases
            break
        }
    }
    
    // MARK: - Weather Search
  
    func searchWeather(location: String) {
        let apiKey = "de2f1bde14337cad1300a6cd9213b172"

        // Format the location string by replacing spaces with '+'
        let formattedLocation = location.replacingOccurrences(of: " ", with: "+")
        
        // Construct the URL for the API request
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(formattedLocation)&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        // Create a URLSession data task to fetch the weather data
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error fetching weather data: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                // Decode the received JSON data into a WeatherData object
                let decoder = JSONDecoder()
                let weatherData = try decoder.decode(WeatherData.self, from: data)
                
                // Update the UI on the main queue with the received weather data
                DispatchQueue.main.async {
                    // Set the location name
                    self.locationNameLabel.text = weatherData.name
                    
                    // Calculate and set the temperature
                    let temperature = Int(weatherData.main.temp - 273.15)
                    self.temperatureLabel.text = "\(temperature)°C"
                    
                    // Set the weather description
                    self.descriptionLabel.text = weatherData.weather.first?.description
                    
                    // Calculate and set the feels like temperature
                    let feelsLike = Int(weatherData.main.feelsLike - 273.15)
                    self.feelsLikeLabel.text = "\(feelsLike)°C"
                    
                    // Calculate and set the minimum temperature
                    let minTemperature = Int(weatherData.main.minTemp - 273.15)
                    self.minTempLabel.text = "\(minTemperature)°C"
                    
                    // Calculate and set the maximum temperature
                    let maxTemperature = Int(weatherData.main.maxTemp - 273.15)
                    self.maxTempLabel.text = "\(maxTemperature)°C"
                    
                    // Calculate and set the wind speed
                    let windSpeed = Int(weatherData.wind.speed * 3.6)
                    self.windSpeedLabel.text = "\(windSpeed)km/h"
                    
                    // Download and set the weather icon
                    if let iconCode = weatherData.weather.first?.icon {
                        let iconURLString = "https://openweathermap.org/img/w/\(iconCode).png"
                        if let iconURL = URL(string: iconURLString) {
                            let task = URLSession.shared.dataTask(with: iconURL) { (data, response, error) in
                                if let error = error {
                                    print("Error downloading weather icon: \(error)")
                                    return
                                }
                                
                                if let data = data, let image = UIImage(data: data) {
                                    DispatchQueue.main.async {
                                        self.weatherIconImage.image = image
                                    }
                                }
                            }
                            
                            task.resume()
                        }
                    }
                }
            } catch {
                print("Error decoding weather data: \(error)")
                DispatchQueue.main.async {
                    self.displayMessage(title: "Error", message: "Invalid location. Please try again with the format 'location followed by country code'.")
                }
            }
        }
        
        // Start the URLSession data task
        task.resume()
    }
    
    // MARK: - Search Bar Delegate
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if let location = searchBar.text{
            searchWeather(location: location)
        }
    }
    
  
    
    // MARK: - Location Manager Delegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Create a CLGeocoder instance to perform reverse geocoding
        let geocoder = CLGeocoder()
        
        // Perform reverse geocoding to obtain placemark for the current location
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("No placemark found")
                return
            }
            
            // Extract the city from the placemark
            if let city = placemark.locality {
                // Call the searchWeather function to fetch weather data for the city
                self.searchWeather(location: city)
            }
        }
        
        // Stop updating the location after retrieving the current location
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Display Message

    func displayMessage(title: String, message: String) {
        // Displays an alert message with the specified title and message.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Search Interface Handling

    // Handles the hiding of the search interface.
    @objc func hideSearch() {
        // Hide or dismiss the search interface
        searchController.searchBar.resignFirstResponder()
        
        // Show the navigation bar
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    

}
