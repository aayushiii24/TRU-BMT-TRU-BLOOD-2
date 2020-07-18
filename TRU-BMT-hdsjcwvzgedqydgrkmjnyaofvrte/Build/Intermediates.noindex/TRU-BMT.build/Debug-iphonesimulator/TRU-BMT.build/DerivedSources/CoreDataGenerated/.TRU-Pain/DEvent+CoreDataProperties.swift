//
//  DEvent+CoreDataProperties.swift
//  
//
//  Created by Aayushi Patel on 7/17/20.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension DEvent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DEvent> {
        return NSFetchRequest<DEvent>(entityName: "DEvent")
    }

    @NSManaged public var date: Date?
    @NSManaged public var dateString: String?
    @NSManaged public var jsonString: String?
    @NSManaged public var method: String?
    @NSManaged public var metric: String?
    @NSManaged public var name: String?
    @NSManaged public var participantID: String?
    @NSManaged public var taskRunUUID: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var timestampString: String?
    @NSManaged public var value: String?

}
