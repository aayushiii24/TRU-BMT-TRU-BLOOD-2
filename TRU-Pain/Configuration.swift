//
//  Configuration.swift
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



//struct Defaults {
//    
//    static let Latitude: Double = 37.8267 //will not use this but will user current location
//    static let Longitude: Double = -122.423 //will not use this but will user current location
//    
//}

struct API {
    
    static let APIKey = "1b6778758dc77c7ac727e17286b546ed"
    static let BaseURL = URL(string: "https://api.forecast.io/forecast/")!
    
    static var AuthenticatedBaseURL: URL {
        return BaseURL.appendingPathComponent(APIKey)
    }
    
}
