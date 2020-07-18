//
//  Care+CoreDataProperties.swift
//  
//
//  Created by Aayushi Patel on 7/17/20.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Care {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Care> {
        return NSFetchRequest<Care>(entityName: "Care")
    }

    @NSManaged public var birthYear: String?
    @NSManaged public var gender: String?
    @NSManaged public var initials: String?
    @NSManaged public var institution: String?
    @NSManaged public var reminder: String?
    @NSManaged public var study: String?

}
