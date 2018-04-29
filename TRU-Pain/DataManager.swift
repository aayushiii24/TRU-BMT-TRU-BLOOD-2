//
//  DataManager.swift
//  TRU-Pain
//
//  Created by jonas002 on 12/4/16.
//  Copyright © 2016 Jude Jonassaint. All rights reserved.
//
//  Thunderstorm (AppCoda tutorial) https://cocoacasts.com/building-a-weather-application-with-swift-3-fetching-weather-data/
//
//  Created by Bart Jacobs on 22/08/16.
//  Copyright © 2016 Cocoacasts. All rights reserved.


import Foundation
import Alamofire
import CoreData
import UIKit
import CoreLocation
import Firebase

enum DataManagerError: Error {
    
    case Unknown
    case FailedRequest
    case InvalidResponse
    
}

final class DataManager {
    
    typealias WeatherDataCompletion = (AnyObject?, DataManagerError?) -> ()
    
    let baseURL: URL
    
    private var _date: Date?
    private var _temp: String?
    private var _location: String?
    private var _weather: String?
    private var _url: URL?
    typealias JSONStandard = Dictionary<String, AnyObject>
    private var _taskUUID: String?
    private var _timestampString: String?
    private var _altitude: Double?
    private var _timestamp: Date?
    private var _dGeoData:DGeoData?
    var managedContext: NSManagedObjectContext!
    
    //FIREBASE//
    var db: Firestore!
    
    
    // MARK: - Initialization
        init(baseURL: URL) {
        self.baseURL = baseURL
         self.managedContext = getContext()


    }

    
    
    //GET ManageObjectContext
    func getContext () -> NSManagedObjectContext {

        let context = NSManagedObjectContext.default()
        return context!
        
    }
    func geocode(latitude: Double, longitude: Double, completion: @escaping (CLPlacemark?, Error?) -> ())  {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                completion(nil, error)
                return
            }
            completion(placemark, nil)
        }
    }

    // MARK: Convenience
    func appMode(email:String) -> String {
        var mode:String = "Production"
        
        let itemsArray = ["AppleUser@icloud.com", "sicklecell@me.com", "trupain@icloud.com", "trupain000@icloud.com", "trupbmt000@icloud.com", "bmtckstudy000@icloud.com"]
        let filteredStrings = itemsArray.filter({(item: String) -> Bool in
            let stringMatch = item.lowercased().range(of: email)
            print("stringMatch \(String(describing: stringMatch))")
            return stringMatch != nil ? true : false
        })
        
        if filteredStrings.count == 0    {
            mode = "Production"
            print("app mode is Production")
        } else {
            mode = "Testing"
            print("app mode is Test")
        }
        return mode
    }
    
    // MARK: - Requesting Data
    
    func weatherDataForLocation(taskUUID: UUID, altitude: Double, latitude: Double, longitude: Double, completion: @escaping WeatherDataCompletion) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        var country:String = ""
        var state:String = ""
        self.geocode(latitude: latitude, longitude: longitude) { placemark, error in
            guard let placemark = placemark, error == nil else { return }
            // you should always update your UI in the main thread
            DispatchQueue.main.async {
                //  update UI here
                print("address1:", placemark.thoroughfare ?? "") //Street name
                print("address2:", placemark.subThoroughfare ?? "") //street number
                print("city:",     placemark.locality ?? "") //City
                print("state:",    placemark.administrativeArea ?? "") //PA
                print("zip code:", placemark.postalCode ?? "") //Zipcode
                print("country:",  placemark.country ?? "") //United States
                print("subAdministrativeArea:",    placemark.subAdministrativeArea ?? "") //Allegheny
                print("region:", placemark.region ?? "") //CLCircularregion
                print("name:",  placemark.name ?? "") //Street address
                country = placemark.country ?? ""
                state = placemark.administrativeArea ?? ""
            }
            
            
        }
        // Create URL
        //let URL = baseURL.appendingPathComponent("\(latitude),\(longitude)")
        _url = baseURL.appendingPathComponent("\(latitude),\(longitude)")
        
        /* Jude:Change instead of using the URLSession data task, we use Alamofire below
        URLSession.shared.dataTask(with: URL) { (data, response, error) in
            self.didFetchWeatherData(data: data, response: response, error: error, completion: completion)
            }.resume()
        */
        
        Alamofire.request(_url!).responseJSON(completionHandler: {
            response in
            let result = response.result
            if let dict = result.value as? JSONStandard {
            var currentWeatherDictionary:Dictionary = dict["currently"] as! Dictionary<String, Any>
                
                //        ["apparentTemperature"] = "58.11";
                //        ["cloudCover"] = "0.21";
                //        ["dewPoint"] = "45.91";
                //        ["humidity"] = "0.64";
                //        ["icon"] = "clear-day";
                //        nearestStormDistance = 0;
                //        ["ozone"] = "361.7";
                //        ["precipIntensity"] = "0.002";
                //        ["precipIntensityError"] = 0;
                //        ["precipProbability"] = "0.06";
                //        ["precipType"] = rain;
                //        ["pressure"] = "1017.31";
                //        ["summary"] = Clear;
                //        ["temperature"] = "58.11";
                //        time = 1524965005;
                //        ["uvIndex"] = 1;
                //        ["visibility"] = 10;
                //        ["windBearing"] = 263;
                //        ["windGust"] = "14.73";
                //        ["windSpeed"] = "9.92";
                
                currentWeatherDictionary["taskUUID"] = String(describing: taskUUID)
                currentWeatherDictionary["altitude"] = altitude
                currentWeatherDictionary["latitude"] = latitude
                let currentWeatherTimestamp = Date(timeIntervalSince1970: currentWeatherDictionary["time"] as! TimeInterval)
                currentWeatherDictionary["currentWeatherDateTime"] = formatter.string(from: currentWeatherTimestamp)
                
                let dayFormatter = DateFormatter()
                dayFormatter.dateFormat = "yyyy-MM-dd"
                currentWeatherDictionary["dateOfEvent"] = dayFormatter.string(from: currentWeatherTimestamp)
                
                
                //currentWeatherDictionary["country"]
                
                
                //FIREBASE//
                var db: Firestore!
                db = Firestore.firestore()
                
                let handle = Auth.auth().addStateDidChangeListener { (auth, user) in
                    if let user = user {
                        
                        let uid = user.uid
                        let email = user.email
                        //let photoURL = user.photoURL
                        
                        currentWeatherDictionary["userID"] = uid
                        currentWeatherDictionary["userEmail"] = email
                        currentWeatherDictionary["appMode"] = self.appMode(email: email!)
                        currentWeatherDictionary["author_id"] = uid
                        currentWeatherDictionary["country"]  = country
                        currentWeatherDictionary["state"] = state
                        currentWeatherDictionary["dataOfType"] = "weather"
                        print("currentWeatherDictionary \(currentWeatherDictionary)")
                        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                            print("version of app \(version)")
                           currentWeatherDictionary["appVersion"] = version
                        }
                        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                            print("version of app \(build)")
                            currentWeatherDictionary["appBuild"] = build
                        }
                        
                        
                        var ref: DocumentReference? = nil
                        ref = db.collection("users").addDocument(data: currentWeatherDictionary) { err in
                            if let err = err {
                                print("Error adding document: \(err)")
                            } else {
                                print("Document added with ID: \(ref!.documentID)")
                            }
                        }
                    }
                }

            } //if let dictionaryends here
            
        }) //alamofire ends here
        
        
    } //weather data for location ends here

    // MARK: - Helper Methods
    
    private func didFetchWeatherData(data: Data?, response: URLResponse?, error: Error?, completion: WeatherDataCompletion) {
        if let _ = error {
            completion(nil, .FailedRequest)
            
        } else if let data = data, let response = response as? HTTPURLResponse {
            if response.statusCode == 200 {
                processWeatherData(data: data, completion: completion)
                
                
            } else {
                completion(nil, .FailedRequest)
            }
            
        } else {
            completion(nil, .Unknown)
        }
    }
    
    private func processWeatherData(data: Data, completion: WeatherDataCompletion) {
        if let JSON = try? JSONSerialization.jsonObject(with: data, options: []) as AnyObject {
            completion(JSON, nil)
            
            print("serialized JSON \(JSON)")
            //Add data to Firebase

            
            
        } else {
            completion(nil, .InvalidResponse)
        }
    }
    
}

