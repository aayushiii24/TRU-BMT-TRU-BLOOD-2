//
//  DAppetite+CoreDataProperties.swift
//  
//
//  Created by Aayushi Patel on 7/17/20.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension DAppetite {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DAppetite> {
        return NSFetchRequest<DAppetite>(entityName: "DAppetite")
    }

    @NSManaged public var appetiteTotal: String?
    @NSManaged public var breakfast: String?
    @NSManaged public var dayString: String?
    @NSManaged public var dinner: String?
    @NSManaged public var lunch: String?
    @NSManaged public var metric: String?
    @NSManaged public var participantID: String?
    @NSManaged public var taskRunUUID: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var timestampEnd: Date?
    @NSManaged public var timestampEndString: String?
    @NSManaged public var timestampString: String?

}
