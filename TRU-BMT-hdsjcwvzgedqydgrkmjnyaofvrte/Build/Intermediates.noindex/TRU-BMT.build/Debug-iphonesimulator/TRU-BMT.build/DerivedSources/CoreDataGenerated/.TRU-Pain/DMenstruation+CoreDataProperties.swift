//
//  DMenstruation+CoreDataProperties.swift
//  
//
//  Created by Aayushi Patel on 7/17/20.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension DMenstruation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DMenstruation> {
        return NSFetchRequest<DMenstruation>(entityName: "DMenstruation")
    }

    @NSManaged public var date: Date?
    @NSManaged public var dateString: String?
    @NSManaged public var dayString: String?
    @NSManaged public var differentiatesPain: String?
    @NSManaged public var differentiatesSCDPainCharacter: String?
    @NSManaged public var firstMorningUrine: String?
    @NSManaged public var lowerAbdominalCramp: String?
    @NSManaged public var menstruating: String?
    @NSManaged public var pad01: String?
    @NSManaged public var pad02: String?
    @NSManaged public var pad03: String?
    @NSManaged public var participantID: String?
    @NSManaged public var spotting: String?
    @NSManaged public var tampon01: String?
    @NSManaged public var tampon02: String?
    @NSManaged public var tampon03: String?
    @NSManaged public var taskRunUUID: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var timestampEnd: Date?
    @NSManaged public var timestampEndString: String?
    @NSManaged public var timestampString: String?

}
