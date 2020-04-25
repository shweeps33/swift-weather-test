//
//  CitiesManager.swift
//  SwiftForecastTest
//
//  Created by David on 25.04.2020.
//  Copyright © 2020 David. All rights reserved.
//

import Foundation

class CitiesManager {
    var cities: [String]?
    var filteredCities: [String] = []
    
    var filteredFinished: (() -> Void)?
    
    init(with file: String) {
        getJSON(from: file)
    }
    
    private func getJSON(from fileName: String) {
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                  let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                  if let jsonResult = jsonResult as? [Dictionary<String, AnyObject>] {
                    if let citiesNames = jsonResult.compactMap({$0["name"]}) as? [String] {
                        cities = citiesNames
                    }
                  }
              } catch {
                print("ERROR occured while trying read local JSON:" + error.localizedDescription)
              }
        }
    }
    
    func filterCities(with predicate: String) {
        if filteredCities.isEmpty, let cities = cities {
            filteredCities = cities
        }
        if predicate.isEmpty {
            filteredCities = []
        } else {
            filteredCities = filteredCities.filter({ $0.lowercased().hasPrefix(predicate)})
        }
        filteredFinished?()
    }
    
    func clearFiltered() {
        filteredCities = []
        filteredFinished?()
    }
}
