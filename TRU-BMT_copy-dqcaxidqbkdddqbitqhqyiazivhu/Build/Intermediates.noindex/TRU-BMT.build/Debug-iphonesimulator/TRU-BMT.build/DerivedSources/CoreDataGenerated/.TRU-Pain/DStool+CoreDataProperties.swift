//
//  DStool+CoreDataProperties.swift
//  
//
//  Created by Aayushi Patel on 7/17/20.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension DStool {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DStool> {
        return NSFetchRequest<DStool>(entityName: "DStool")
    }

    @NSManaged public var date: Date?
    @NSManaged public var dateString: String?
    @NSManaged public var dayString: String?
    @NSManaged public var diarrheaEpisodes: String?
    @NSManaged public var participantID: String?
    @NSManaged public var particpantID: String?
    @NSManaged public var stools: String?
    @NSManaged public var taskRunUUID: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var timestampEnd: Date?
    @NSManaged public var timestampEndString: String?
    @NSManaged public var timestampString: String?
    @NSManaged public var type1: String?
    @NSManaged public var type2: String?
    @NSManaged public var type3: String?
    @NSManaged public var type4: String?
    @NSManaged public var type5: String?
    @NSManaged public var type6: String?
    @NSManaged public var type7: String?

}
