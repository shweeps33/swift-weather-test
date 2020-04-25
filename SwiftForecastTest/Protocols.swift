//
//  Protocols.swift
//  SwiftForecastTest
//
//  Created by David on 25.04.2020.
//  Copyright © 2020 David. All rights reserved.
//

import Foundation
import UIKit

protocol WeatherFetchable: class {
    func fetchingWeatherFinished(with: Weather)
    func fetchingIconFinished(with: UIImage)
}
