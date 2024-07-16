//
//  WeatherData.swift
//  FIT3178-Assignment
//
//  Created by Zhi Ning Ku on 15/5/2023.
//

import UIKit

class WeatherData: NSObject, Decodable {
    var name: String
    var main: Main
    var weather: [Weather]
    var wind: Wind
    
    // Coding keys for decoding
    private enum CodingKeys: String, CodingKey {
        case name
        case main
        case weather
        case wind
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        main = try container.decode(Main.self, forKey: .main)
        weather = try container.decode([Weather].self, forKey: .weather)
        wind = try container.decode(Wind.self, forKey: .wind)
    }
}

struct Main: Decodable {
    var temp: Double
    var minTemp: Double
    var maxTemp: Double
    var feelsLike: Double
    
    // Coding keys for decoding
    private enum CodingKeys: String, CodingKey {
        case temp
        case minTemp = "temp_min"
        case maxTemp = "temp_max"
        case feelsLike = "feels_like"
    }
}

struct Weather: Decodable {
    var description: String
    var icon: String
    
    // Coding keys for decoding
    private enum CodingKeys: String, CodingKey {
        case description
        case icon
    }
}

struct Wind: Decodable {
    var speed: Double
}







