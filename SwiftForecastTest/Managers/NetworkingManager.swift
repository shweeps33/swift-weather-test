//
//  NetworkingManager.swift
//  SwiftForecastTest
//
//  Created by David on 25.04.2020.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit
import Foundation

private let baseURL = "https://api.openweathermap.org/data/2.5/weather?q="
private let apiKeyParam = "APPID=d0021e2064859afed854c1a3e81d89e3"
private let unitsParam = "units=metric"
private let iconsBaseURL = "https://openweathermap.org/img/wn/"
private let iconExtension = "@2x.png"

class NetworkingManager {
    weak var delegate: WeatherFetchable?
    
    func requestWeather(for city: String) {
        let urlString = baseURL + city + "&" + apiKeyParam + "&" + unitsParam
        guard let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
        let url = URL(string: encodedUrlString) else {
            print("ERROR during creating URL for weather request")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil, let usableData=data {
                do {
                    let json = try JSONSerialization.jsonObject(with: usableData, options: [])
                    if let jsonResult = json as? [String: Any] {
                        if let weather = jsonResult["weather"] as? [[String: Any]],
                            let weatherFirst = weather.first,
                            let temp = jsonResult["main"] as? [String: Double] {
                            
                            let weather = Weather(weather: weatherFirst, temp: temp)
                            self.delegate?.fetchingWeatherFinished(with: weather)
                        }
                    }
                } catch {
                    print("JSON error: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    
    func fetchIcon(name: String) {
        guard let url = URL(string: iconsBaseURL + name + iconExtension) else { return }
        
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    self?.delegate?.fetchingIconFinished(with: image)
                }
            } else {
                print("ERROR during fetching icon")
            }
        }
    }
    
}
