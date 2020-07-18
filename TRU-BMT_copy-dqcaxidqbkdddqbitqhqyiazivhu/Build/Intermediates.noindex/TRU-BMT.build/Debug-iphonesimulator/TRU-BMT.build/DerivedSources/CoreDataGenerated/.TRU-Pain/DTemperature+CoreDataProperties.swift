//
//  DTemperature+CoreDataProperties.swift
//  
//
//  Created by Aayushi Patel on 7/17/20.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension DTemperature {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DTemperature> {
        return NSFetchRequest<DTemperature>(entityName: "DTemperature")
    }

    @NSManaged public var date: Date?
    @NSManaged public var dateString: String?
    @NSManaged public var dayString: String?
    @NSManaged public var intensity: String?
    @NSManaged public var method: String?
    @NSManaged public var metric: String?
    @NSManaged public var name: String?
    @NSManaged public var participantID: String?
    @NSManaged public var taskRunUUID: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var timestampEnd: Date?
    @NSManaged public var timestampEndString: String?
    @NSManaged public var timestampString: String?

}
