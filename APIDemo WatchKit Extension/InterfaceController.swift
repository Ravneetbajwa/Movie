//
//  InterfaceController.swift
//  APIDemo WatchKit Extension
//
//  Created by Parrot on 2019-03-03.
//  Copyright © 2019 Parrot. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire
import SwiftyJSON
import CoreLocation

class InterfaceController: WKInterfaceController {

    // MARK: Outlets
    @IBOutlet var sunriseLabel: WKInterfaceLabel!
    @IBOutlet var sunsetLabel: WKInterfaceLabel!
    @IBOutlet var cityLabel: WKInterfaceLabel!
    
    @IBOutlet var loadingSunriseImage: WKInterfaceImage!
    @IBOutlet var loadingSunsetImage: WKInterfaceImage!
    
    
    // MARK: variables
    var cityCoordinates:CLLocationCoordinate2D?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        let preferences = UserDefaults.standard
        
        print("SHARED PREFERENCES OUTPUT")
        print(preferences.string(forKey: "savedLat"))
        print(preferences.string(forKey: "savedLng"))
        print(preferences.string(forKey: "savedCity"))
        
        
        var lat = preferences.string(forKey:"savedLat")
        var lng = preferences.string(forKey:"savedLng")
        var movie = preferences.string(forKey:"savedCity")
        
        if (lat == nil || lng == nil || movie == nil) {
            lat = "49.2827"
            lng = "-123.1207"
            movie = "Badla"
           
        }
        
        // Update UI
         self.cityLabel.setText(movie)
        
        // start animations
        self.showLoadingAnimations()
        
        // TODO: Put your API call here
        
        let URL = "https://api.themoviedb.org/3/search/movie?api_key=07565b3fca7322c745e9a8679055c00a&query=\(movie!)"
        print("Url: \(URL)")
        Alamofire.request(URL).responseJSON {
            // 1. store the data from the internet in the
            // response variable
            response in
            
            // 2. get the data out of the variable
            guard let apiData = response.result.value else {
                print("Error getting data from the URL")
                return
            }
            // GET sunrise/sunset time out of the JSON response
            let jsonResponse = JSON(apiData)
            let sunriseTime = jsonResponse["results"][0]["title"].string
            let sunsetTime = jsonResponse["results"][0]["release_date"].string
            
            // display in a UI
            self.sunriseLabel.setText("\(sunriseTime!)")
            self.sunsetLabel.setText("\(sunsetTime!)")
            
            // stop the loading animation
            self.stopAnimations()
        }
    }
   
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    
    // MARK: Actions

    @IBOutlet var changeMovie: WKInterfaceLabel!
    
    func showLoadingAnimations() {
        // animate the sunrise label
        self.loadingSunriseImage.setImageNamed("Progress")
        self.loadingSunriseImage.startAnimatingWithImages(in: NSMakeRange(0, 10), duration: 1, repeatCount: 0)
        self.sunriseLabel.setText("Updating...")

        // animate the sunset label
        self.loadingSunsetImage.setImageNamed("Progress")
        self.loadingSunsetImage.startAnimatingWithImages(in: NSMakeRange(0, 10), duration: 1, repeatCount: 0)
        self.sunsetLabel.setText("Updating...")
    }
    
    func stopAnimations() {
        // sunrise loading image
        self.loadingSunriseImage.stopAnimating()
        self.loadingSunriseImage.setImage(nil)

        // sunset loading image
        self.loadingSunsetImage.stopAnimating()
        self.loadingSunsetImage.setImage(nil)
    }
    
}
