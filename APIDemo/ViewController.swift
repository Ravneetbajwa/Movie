//
//  ViewController.swift
//  APIDemo
//
//  Created by Parrot on 2019-03-03.
//  Copyright © 2019 Parrot. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class ViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    
    
    @IBOutlet weak var savedCityLabel: UILabel!
    
    // MARK: Variables
    var cityCoordinates:CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let URL = "https://api.sunrise-sunset.org/json?lat=49.2827&lng=-123.1207&date=today"
        
        Alamofire.request(URL).responseJSON {
            // 1. store the data from the internet in the
            // response variable
            response in
            
            // 2. get the data out of the variable
            guard let apiData = response.result.value else {
                print("Error getting data from the URL")
                return
            }
            
            // OUTPUT the entire json response to the terminal
            print(apiData)
            
            
            // GET sunrise/sunset time out of the JSON response
            let jsonResponse = JSON(apiData)
            let sunriseTime = jsonResponse["results"]["sunrise"].string
            let sunsetTime = jsonResponse["results"]["sunset"].string
            
            
            // DEBUG:  Output it to the terminal
            print("Sunrise: \(sunriseTime)")
            print("Sunset: \(sunsetTime)")
            
            // display in a UI
            self.sunriseLabel.text = "\(sunriseTime!)"
            self.sunsetLabel.text = "\(sunsetTime!)"
        }
    
        self.geocode(cityName: "Toronto")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func geocode(cityName:String) {
        let geocoder = CLGeocoder()
        print("Trying to geocode \(cityName) to lat/lng")
        geocoder.geocodeAddressString(cityName) {
            
            (placemarks, error) in
            
            print("Got a response")
            // Process Response
            if let error = error {
                print("Unable to Forward Geocode Address (\(error))")
                self.savedCityLabel.text = "Unable to Find Location for Address"
                self.cityCoordinates = nil
            } else {
                var location: CLLocation?
                
                if let placemarks = placemarks, placemarks.count > 0 {
                    location = placemarks.first?.location
                    self.cityCoordinates = location?.coordinate
                }
                
                if let location = location {
                    self.cityCoordinates = location.coordinate
                    
                } else {
                    print("No matching location found")
                    self.savedCityLabel.text = "No Matching Location Found"
                    self.cityCoordinates = nil
                }
            }
            
            print("City coordinates: \(self.cityCoordinates)")
        }
    }
}

