//
//  WeatherViewController.swift
//  SwiftForecastTest
//
//  Created by David on 25.04.2020.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController {
    var city = ""
    var weather: Weather?
    
    private var isWeatherLoaded: Bool? {
        didSet {
            feelsLikeStackView.isHidden = !(isWeatherLoaded ?? false)
            temperatureStackView.isHidden = !(isWeatherLoaded ?? false)
        }
    }
    
    var networking = NetworkingManager()

    @IBOutlet weak var temperatureStackView: UIStackView!
    @IBOutlet weak var feelsLikeStackView: UIStackView!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var conditions: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isWeatherLoaded = false
        networking.requestWeather(for: city)
        networking.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Weather in " + city
    }
}

extension WeatherViewController: WeatherFetchable {
    func fetchingIconFinished(with image: UIImage) {
        DispatchQueue.main.async {
            self.iconView.image = image
        }
    }
    
    func fetchingWeatherFinished(with weather: Weather) {
        DispatchQueue.main.async {
            self.conditions.text = weather.description
            self.tempLabel.text = weather.temp
            self.feelsLikeLabel.text = weather.feelsTemp
            self.isWeatherLoaded = true
        }
        networking.fetchIcon(name: weather.icon)
    }
}
