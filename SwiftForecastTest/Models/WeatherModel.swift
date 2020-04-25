//
//  WeatherModel.swift
//  SwiftForecastTest
//
//  Created by David on 25.04.2020.
//  Copyright © 2020 David. All rights reserved.
//

import Foundation

struct Weather {
    let description: String
    let icon: String
    let temp: String
    let feelsTemp: String
    
    init(weather: [String: Any], temp: [String: Double]) {
        description = (weather["description"] as? String)?.capitalized ?? "Unknown"
        icon = weather["icon"] as? String ?? ""
        if let temperature = temp["temp"] {
            self.temp = "\(temperature)"
        } else {
            self.temp = ""
        }
        if let feelsLike = temp["feels_like"] {
            feelsTemp = "\(feelsLike)"
        } else {
            feelsTemp = ""
        }
    }
}
