//
//  DGeospatial+CoreDataProperties.swift
//  
//
//  Created by Aayushi Patel on 7/17/20.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension DGeospatial {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DGeospatial> {
        return NSFetchRequest<DGeospatial>(entityName: "DGeospatial")
    }

    @NSManaged public var altitude: String?
    @NSManaged public var apparentTemperature: String?
    @NSManaged public var cloudCover: String?
    @NSManaged public var dewPoint: String?
    @NSManaged public var humidity: String?
    @NSManaged public var icon: String?
    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?
    @NSManaged public var ozone: String?
    @NSManaged public var precipIntensity: String?
    @NSManaged public var precipProbability: String?
    @NSManaged public var pressure: String?
    @NSManaged public var summary: String?
    @NSManaged public var taskUUID: String?
    @NSManaged public var temperature: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var timestampString: String?
    @NSManaged public var visibility: String?
    @NSManaged public var windSpeed: String?

}
