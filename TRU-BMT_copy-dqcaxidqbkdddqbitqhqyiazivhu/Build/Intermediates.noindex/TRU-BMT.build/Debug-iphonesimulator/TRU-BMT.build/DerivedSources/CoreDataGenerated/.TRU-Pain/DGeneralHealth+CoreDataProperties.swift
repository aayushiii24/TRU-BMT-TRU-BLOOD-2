//
//  DGeneralHealth+CoreDataProperties.swift
//  
//
//  Created by Aayushi Patel on 7/17/20.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension DGeneralHealth {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DGeneralHealth> {
        return NSFetchRequest<DGeneralHealth>(entityName: "DGeneralHealth")
    }

    @NSManaged public var activityLimitation: String?
    @NSManaged public var date: Date?
    @NSManaged public var dateString: String?
    @NSManaged public var dayString: String?
    @NSManaged public var fatigue: String?
    @NSManaged public var generalHealth: String?
    @NSManaged public var generalHealthComparison: String?
    @NSManaged public var metric: String?
    @NSManaged public var mood: String?
    @NSManaged public var participantID: String?
    @NSManaged public var sleepHours: String?
    @NSManaged public var sleepQuality: String?
    @NSManaged public var stress: String?
    @NSManaged public var symptomInterference: String?
    @NSManaged public var taskRunUUID: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var timestampEnd: Date?
    @NSManaged public var timestampEndString: String?
    @NSManaged public var timestampString: String?

}
