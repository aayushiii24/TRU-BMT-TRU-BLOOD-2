//
//  DGeoData+CoreDataProperties.swift
//  
//
//  Created by Aayushi Patel on 7/17/20.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension DGeoData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DGeoData> {
        return NSFetchRequest<DGeoData>(entityName: "DGeoData")
    }

    @NSManaged public var altitude: String?
    @NSManaged public var apparentTemperature: String?
    @NSManaged public var apparentTemperatureMax: String?
    @NSManaged public var apparentTemperatureMin: String?
    @NSManaged public var cloudCover: String?
    @NSManaged public var currentWeatherTimestampString: String?
    @NSManaged public var dailySummary: String?
    @NSManaged public var dewPoint: String?
    @NSManaged public var humidity: String?
    @NSManaged public var icon: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var moonPhase: String?
    @NSManaged public var ozone: String?
    @NSManaged public var participantID: String?
    @NSManaged public var pressure: String?
    @NSManaged public var summary: String?
    @NSManaged public var sunriseTimeString: String?
    @NSManaged public var sunsetTimeTimeString: String?
    @NSManaged public var taskUUID: String?
    @NSManaged public var temperature: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var timestampString: String?
    @NSManaged public var visibility: String?
    @NSManaged public var windSpeed: String?

}
