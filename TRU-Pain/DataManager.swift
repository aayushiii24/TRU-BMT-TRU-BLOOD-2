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
        let utcDateFormatter = DateFormatter()
        utcDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "yyyy-MM-dd"
        
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
        
        
        
        
        /*AF.request(_url!).responseJSON(completionHandler: {
            response in
            let result = response.result
            if let dict = result.value as? JSONStandard {
            var currentWeatherDictionary:Dictionary = dict["currently"] as! Dictionary<String, Any>
                
                let todayDictionary = dict["daily"] as? JSONStandard
                let data = todayDictionary?["data"] as! NSArray
                var dataJ:Dictionary = (data[0] as? Dictionary<String, Any>)!
                
                print("dataJ")
                print(data)
                
                print("dataJ")
                print(dataJ ?? "-999")
                print(dataJ["moonPhase"] as! Double)
                var dailyWeatherDictionary:Dictionary = [String: String]()
                
                let apparentTemperatureMax = String(dataJ["apparentTemperatureMax"] as! Double)
                let apparentTemperatureMin = String(dataJ["apparentTemperatureMin"] as! Double)
                let temperatureLow = String(dataJ["temperatureLow"] as! Double)
                let temperatureMin = String(dataJ["temperatureMin"] as! Double)
                let sunsetTimestamp = Date(timeIntervalSince1970: dataJ["sunsetTime"] as! TimeInterval)
                let sunsetTimestampString = utcDateFormatter.string(from: sunsetTimestamp)
                let dailyWeatherTimestamp = Date(timeIntervalSince1970: dataJ["time"] as! TimeInterval)
                let precipitationProbability = String(dataJ["precipProbability"] as! Double)
                let sunriseTimestamp = Date(timeIntervalSince1970: dataJ["sunriseTime"] as! TimeInterval)
                let sunriseTimestampString = utcDateFormatter.string(from: sunriseTimestamp)
                let dailyWeatherDateOfEvent = dayFormatter.string(from: dailyWeatherTimestamp)
                let dailyWeatherSummary = String(dataJ["summary"] as! String)
                
                dailyWeatherDictionary["precipitationProbability"] = precipitationProbability
                dailyWeatherDictionary["apparentTemperatureMax"] = apparentTemperatureMax
                dailyWeatherDictionary["apparentTemperatureMin"] = apparentTemperatureMin
                dailyWeatherDictionary["temperatureLow"] = temperatureLow
                dailyWeatherDictionary["temperatureMin"] = temperatureMin
                dailyWeatherDictionary["sunriseTimestampString"] = sunriseTimestampString
                dailyWeatherDictionary["sunsetTimestampString"] = sunsetTimestampString
                dailyWeatherDictionary["dailyWeatherDateOfEvent"] = dailyWeatherDateOfEvent
                dailyWeatherDictionary["dailyWeatherSummary"] = dailyWeatherSummary
                
                currentWeatherDictionary["taskUUID"] = String(describing: taskUUID)
                currentWeatherDictionary["altitude"] = altitude
                let currentWeatherTimestamp = Date(timeIntervalSince1970: currentWeatherDictionary["time"] as! TimeInterval)
                currentWeatherDictionary["currentWeatherDateTime"] = utcDateFormatter.string(from: currentWeatherTimestamp)
                currentWeatherDictionary["dateOfEvent"] = dayFormatter.string(from: currentWeatherTimestamp)
                
                
                //currentWeatherDictionary["country"]
                
                
                //FIREBASE//
                
                
                
                self.db = Firestore.firestore()
                
                let handle = Auth.auth().addStateDidChangeListener { (auth, user) in
                    if let user = user {
                        
                        let uid = user.uid
                        let email = user.email
                        //let photoURL = user.photoURL
                        
                        print("self.appMode(email: email) out \(self.appMode(email: email!))")
                        
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
                        ref = self.db.collection("current_weathers").addDocument(data: currentWeatherDictionary) { err in
                            if let err = err {
                                print("Error adding document: \(err)")
                            } else {
                                print("current weather Document added with ID: \(ref!.documentID)")
                            }
                        }
                       
                        dailyWeatherDictionary["taskUUID"] = String(describing: taskUUID)
                        dailyWeatherDictionary["altitude"] = String(altitude)
                        dailyWeatherDictionary["latitude"] = String(latitude)
                        dailyWeatherDictionary["userID"] = uid
                        dailyWeatherDictionary["userEmail"] = email
                        dailyWeatherDictionary["appMode"] = self.appMode(email: email!)
                        dailyWeatherDictionary["author_id"] = uid
                        dailyWeatherDictionary["country"]  = country
                        dailyWeatherDictionary["state"] = state
                        dailyWeatherDictionary["dataOfType"] = "daily_weather"
                        print("currentWeatherDictionary \(String(describing: dataJ))")
                        
                        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                            print("version of app \(version)")
                            dailyWeatherDictionary["appVersion"] = version
                        }
                        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                            print("version of app \(build)")
                            dailyWeatherDictionary["appBuild"] = build
                        }
                        
                        dailyWeatherDictionary["taskUUID"] = String(describing: taskUUID)
                        dailyWeatherDictionary["altitude"] = String(altitude)
                        
                        
                        let dayFormatter = DateFormatter()
                        dayFormatter.dateFormat = "yyyy-MM-dd"
                        let dateString = dayFormatter.string(from: dailyWeatherTimestamp)
                        dataJ["dateOfEvent"] = dateString
                        
                        
                        
                        
                        //"dailyWeather" + dateString + "." +
                        
                        
                        
                        print("dailyweather dictionary \(dailyWeatherDictionary)")
                        
                        let idForFirestore = "daily_weather." + dateString + "." + uid
                        
                        
                        var dailyWeatherRef: DocumentReference? = nil
                        self.db.collection("daily_weathers").document(idForFirestore).setData(dailyWeatherDictionary) { err in
                            print("self.appMode(email: email!) inside dailyWeather \(self.appMode(email: email!))")
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document successfully written!")
                            }
                        }
                    }

                }

            } //if let dictionaryends here
            
        }) //alamofire ends here */
        
        
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

