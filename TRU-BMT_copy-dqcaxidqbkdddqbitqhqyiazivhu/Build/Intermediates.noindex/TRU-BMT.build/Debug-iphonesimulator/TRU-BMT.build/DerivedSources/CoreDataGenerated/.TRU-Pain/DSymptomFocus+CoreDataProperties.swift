//
//  DSymptomFocus+CoreDataProperties.swift
//  
//
//  Created by Aayushi Patel on 7/17/20.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension DSymptomFocus {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DSymptomFocus> {
        return NSFetchRequest<DSymptomFocus>(entityName: "DSymptomFocus")
    }

    @NSManaged public var date: Date?
    @NSManaged public var dateString: String?
    @NSManaged public var dayString: String?
    @NSManaged public var intensity: String?
    @NSManaged public var interventions: String?
    @NSManaged public var metric: String?
    @NSManaged public var name: String?
    @NSManaged public var otherInterventions: String?
    @NSManaged public var participantID: String?
    @NSManaged public var status: String?
    @NSManaged public var taskRunUUID: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var timestampEnd: Date?
    @NSManaged public var timestampEndString: String?
    @NSManaged public var timestampString: String?
    @NSManaged public var triggers: String?

}
