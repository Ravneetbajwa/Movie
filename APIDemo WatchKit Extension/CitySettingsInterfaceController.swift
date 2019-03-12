//
//  CitySettingsInterfaceController.swift
//  APIDemo WatchKit Extension
//
//  Created by Parrot on 2019-03-04.
//  Copyright © 2019 Parrot. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire
import SwiftyJSON

class CitySettingsInterfaceController: WKInterfaceController {

    // MARK: Outlets
    @IBOutlet var savedCityLabel: WKInterfaceLabel!
    @IBOutlet var loadingImage: WKInterfaceImage!
    @IBOutlet var saveButtonLabel: WKInterfaceLabel!

    // MARK: Variables
    var movie:String!
    var latitude:String?
    var longitude:String?

    // MARK: API KEYS
    let API_KEY = "bb1312b9aea363"
    var mainVC:InterfaceController?
    
    @IBAction func selectCityPressed() {
        // 1. When person clicks on button, show them the input UI
        let suggestedResponses = ["Black Panther", "The Avengers", "Captain Marvel ", "The Dark Knight"]
        presentTextInputController(withSuggestions: suggestedResponses, allowedInputMode: .plain) {
            
            (results) in
            
            if (results != nil && results!.count > 0) {
                // 2. write your code to process the person's response
                let userResponse = results?.first as? String
                self.savedCityLabel.setText(userResponse)
                self.movie = userResponse
            }
        }
    }
    
    @IBAction func saveButtonPressed() {
        print("Getting City")
        self.geocode(cityName: self.movie)
    }
 
    
    func geocode(cityName:String) {
        
        // Encode the city name
        let cityParam = cityName.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        
        
        // start showing the loading image
        
        self.loadingImage.setImageNamed("Progress")
        self.loadingImage.startAnimatingWithImages(in: NSMakeRange(0, 10), duration: 1, repeatCount: 0)
        self.saveButtonLabel.setText("Saving...")
        
        
        let URL = "https://api.themoviedb.org/3/search/movie?api_key=07565b3fca7322c745e9a8679055c00a&query=\(movie!)"
        print(URL)
        Alamofire.request(URL).responseJSON {
            // 1. store the data from the internet in the
            // response variable
            response in
            
            // 2. get the data out of the variable
            guard let apiData = response.result.value else {
                print("Error getting data from the URL")
                return
            }
            // Get the lat/long component out of the response url
            var jsonResponse = JSON(apiData)
            print(jsonResponse)
            let results = jsonResponse.array?.first
            
            if (results == nil) {
                print("Error parsing results from JSON response")
                return
            }
            
            let data = JSON(results)
            self.latitude = data["lat"].string
            self.longitude = data["lon"].string

            print("Lat: \(self.latitude)")
            print("Long: \(self.longitude)")
            
            
            // save this to Shared Preferences
            let preferences = UserDefaults.standard
            preferences.set(self.latitude, forKey:"savedLat")
            preferences.set(self.longitude, forKey:"savedLng")
            preferences.set(self.movie, forKey:"savedCity")
            
            // dismiss the View Controller
            self.popToRootController()
            
            
            self.loadingImage.stopAnimating()
        }
        
        
        // MARK: Geocoding with CoreLocation libraries
        // -------------
    
        //Note:  This is the code for performing geolocation with the built in CoreLocation library.
        //But, the code doesn't work properly with the watchOS Emulator.
        //It WILL work with a real watch -- just not the simulator.
        //This code remains here for reference purposes
        
        /*
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(cityName, completionHandler: {
            
            (placemarks, error) -> Void in
            
            if((error) != nil){
                print("Error", error)
            }
            if let placemark = placemarks?.first {
                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                print(coordinates)
            }
        })
        */
        
    }
    
    // MARK: Default functions
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // get name of city in shared preferences
        let preferences = UserDefaults.standard
        guard let savedCity = preferences.string(forKey: "savedCity") else {
            return
        }
        
        self.savedCityLabel.setText(savedCity)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
