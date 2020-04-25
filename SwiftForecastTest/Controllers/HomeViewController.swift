//
//  HomeViewController.swift
//  SwiftForecastTest
//
//  Created by David on 25.04.2020.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class HomeViewController: UIViewController {

    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var showWeatherButton: UIButton!
    @IBOutlet weak var myLocation: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var locationStatus = CLLocationManager.authorizationStatus()
    let locationManager = CLLocationManager()
    let activityView = UIActivityIndicatorView(style: .large)
    
    var model: CitiesManager?
    var currentCity = "" {
        didSet {
            searchBar.text = currentCity
        }
    }
    
    var isForecastButtonEnabled: Bool? {
        didSet {
            showWeatherButton.isEnabled = isForecastButtonEnabled ?? false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        searchBar.delegate = self
        resultTableView.delegate = self
        resultTableView.dataSource = self
        
        model = CitiesManager(with: "cities")
        
        model?.filteredFinished = {
            self.resultTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureUI()
    }

    @IBAction func showWeather(_ sender: UIButton) {
    }
    
    @IBAction func myLocation(_ sender: UIButton) {
        guard locationStatus != .notDetermined else {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        switch locationStatus {
        case .authorizedWhenInUse:
            activityView.startAnimating()
            activityView.isHidden = false
            
            locationManager.requestLocation()
        default:
            showAlert()
        }
    }
    
    private func configureUI() {
        activityView.center = view.center
        view.addSubview(activityView)
        activityView.isHidden = true
        activityView.hidesWhenStopped = true
        
        resultTableView.keyboardDismissMode = .onDrag
        
        isForecastButtonEnabled = false
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: "Sorry", message: "Location is currently unavailable", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is WeatherViewController {
            let vc = segue.destination as? WeatherViewController
            vc?.city = self.currentCity
            
        }
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationStatus = status
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        activityView.stopAnimating()
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if error == nil {
                if let firstLocation = placemarks?[0].locality {
                    self.currentCity = firstLocation
                    self.isForecastButtonEnabled = true
                }
            } else {
                print("ERROR with getting locality")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR with getting current location, error: \(error.localizedDescription)")
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCity = model?.filteredCities[indexPath.row] else { return }
        
        currentCity = selectedCity
        model?.clearFiltered()
        isForecastButtonEnabled = true
        view.endEditing(true)
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model?.filteredCities.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath)
        
        cell.textLabel?.text = model?.filteredCities[indexPath.row]
        
        return cell
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        model?.filterCities(with: searchText.lowercased())
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}
