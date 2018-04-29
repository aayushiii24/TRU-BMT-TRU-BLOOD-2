//
//  ListDataManager.swift
//  TRU-BLOOD
//
//  Created by jonas002 on 12/25/16.
//  Copyright © 2016 scdi. All rights reserved.
//

import Foundation
import CoreData
import UIKit


final class ListDataManager {
    var managedContext: NSManagedObjectContext!
    
    func getArrayFor(string:String) -> Array<String> {
        print("string passed to func \(string)")
        let keychain = KeychainSwift()
        let listOfCSV = keychain.get(string)
        var array = [String]()
        var sortedArray = [String]()
        let tempArray = listOfCSV!.components(separatedBy: ",")
        for item in tempArray {
            let rawString:String = String.localizedStringWithFormat("%@", item)
            let trimmedString:String = rawString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            array.append(trimmedString)
        }
        if (string != "Body Locations") {
            sortedArray = array.sorted()
        } else {
            sortedArray = array
        }
        
        
        return sortedArray
    }
    
    //INITIALIZE the class
    init() {
        self.managedContext = getContext()
        
    }
    
    
    //GET ManageObjectContext
    func getContext () -> NSManagedObjectContext {
        let context = NSManagedObjectContext.default()
        return context!
    }
    
    
    //CREATE entity
    func createGeoData(entityName: String) -> DGeoData {
        let entity = NSEntityDescription.entity(
            forEntityName: entityName,
            in: managedContext)!
        let geoData = DGeoData(entity: entity,
                            insertInto: managedContext)
    
    return geoData
    }
    
    
    
    func createGeneralHealth(entityName: String) -> DGeneralHealth {
        let context = getContext()
        let entity = NSEntityDescription.entity(
            forEntityName: entityName,
            in: context)!
        
        let generalHealth = NSManagedObject(entity: entity,
                               insertInto: context)
        
        return generalHealth as! DGeneralHealth
    }
    
    func createSymptomFocus(entityName: String) -> DSymptomFocus {
        let entity = NSEntityDescription.entity(
            forEntityName: entityName,
            in: managedContext)!
        let symptomFocus = DSymptomFocus(entity: entity,
                                           insertInto: managedContext)
        
        return symptomFocus
    }
    
    func createDStool(entityName: String) -> DStool {
        let entity = NSEntityDescription.entity(
            forEntityName: entityName,
            in: managedContext)!
        let stool = DStool(entity: entity,
                                         insertInto: managedContext)
        
        return stool
    }
    
    func createDMenstruation(entityName: String) -> DMenstruation {
        let entity = NSEntityDescription.entity(
            forEntityName: entityName,
            in: managedContext)!
        let menstruation = DMenstruation(entity: entity,
                                         insertInto: managedContext)
        
        return menstruation
    }
    
    func createDscdPain(entityName: String) -> DscdPain {
        let entity = NSEntityDescription.entity(
            forEntityName: entityName,
            in: managedContext)!
        let scdPain = DscdPain(entity: entity,
                                         insertInto: managedContext)
        
        return scdPain
    }
    
    func createDTemperature(entityName: String) -> DTemperature {
        let entity = NSEntityDescription.entity(
            forEntityName: entityName,
            in: managedContext)!
        let temperature = DTemperature(entity: entity,
                               insertInto: managedContext)
        
        return temperature
    }
    
    func createDAppetite(entityName: String) -> DAppetite {
        let entity = NSEntityDescription.entity(
            forEntityName: entityName,
            in: managedContext)!
        let appetite = DAppetite(entity: entity,
                                       insertInto: managedContext)
        
        return appetite
    }

    
  
    
    
    //FETCH entities
    
    func findAppetite(entityName: String) -> [DAppetite] {
        let request = NSFetchRequest<DAppetite>(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        request.sortDescriptors = [sortDescriptor ]
        
        var results =  [DAppetite]()
        
        do {
            results =  try managedContext.fetch(request)
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return results
    }

    
    func findGeoData(entityName: String, taskUUID: String) -> Array<Any> {
        let request = NSFetchRequest<DGeoData>(entityName: "DGeoData")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let taskUUIDPredicate = NSPredicate(format: "taskUUID == %@", taskUUID)
        request.predicate = taskUUIDPredicate
        request.sortDescriptors = [sortDescriptor ]
        
        var results = [DGeoData]()
        
        do {
            results =  try getContext().fetch(request)
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return results
    }
    
    
    func findGeneralHealth(entityName: String) -> [DGeneralHealth] {
        let request = NSFetchRequest<DGeneralHealth>(entityName: "DGeneralHealth")
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        request.sortDescriptors = [sortDescriptor ]
        
        var results =  [DGeneralHealth]()
        
        do {
            results =  try getContext().fetch(request)
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return results
    }
    
    
    func findSymptomFocus(entityName: String) -> [DSymptomFocus] {
        let request = NSFetchRequest<DSymptomFocus>(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortDescriptor ]
        
        var results =  [DSymptomFocus]()
        
        do {
            results =  try managedContext.fetch(request)
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return results
    }
    
    func findTodaySymptomFocus(date: String) -> String {
        let request = NSFetchRequest<DSymptomFocus>(entityName: "DSymptomFocus")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortDescriptor ]
        let predicate = NSPredicate(format: "dayString == %@", date)
        request.predicate = predicate
        
        var results =  [DSymptomFocus]()
        var archive:String = " "
        var arr:[String]? = []
        do {
            
            results =  try managedContext.fetch(request)
            
            
            for (index,symptom) in results.enumerated() {
                print(symptom.name ?? "-99")
                if index >= 0 {
                    guard let string = symptom.name, let intenstity = symptom.intensity else {
                        break
                    }
                    let intensityValue = intenstity.replacingOccurrences(of: ".0", with: "")
                    
                    arr?.append(string+"("+intensityValue+")")
                }
                
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        let uniqueArray = Array(Set(arr!))
        
        archive = uniqueArray.joined(separator:",")
        print("uniqueArray to archive \(archive)")
        print(uniqueArray, arr ?? "-999", archive )
        return archive
    }

    
    
    func findDStool(entityName: String) -> [DStool] {
        let request = NSFetchRequest<DStool>(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortDescriptor ]
        
        var results =  [DStool]()
        
        do {
            results =  try managedContext.fetch(request)
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return results
    }
    
    
    func findDMenstruation(entityName: String) -> [DMenstruation] {
        let request = NSFetchRequest<DMenstruation>(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortDescriptor ]
        
        var results =  [DMenstruation]()
        
        do {
            results =  try managedContext.fetch(request)
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return results
    }
    
    
    func findDscdPain(entityName: String) -> [DscdPain] {
        let request = NSFetchRequest<DscdPain>(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortDescriptor ]
        
        var results =  [DscdPain]()
        
        do {
            results =  try managedContext.fetch(request)
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return results
    }
    
    
    func findDTemperature(entityName: String) -> [DTemperature] {
        let request = NSFetchRequest<DTemperature>(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortDescriptor ]
        
        var results =  [DTemperature]()
        
        do {
            results =  try managedContext.fetch(request)
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return results
    }
    
    //SAVE entity
    func saveCareData () {
        let context = getContext()
        
        do {
            try context.save()
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

    //SAVE entity
    func saveGeoData () {
        print("get context")
        let context = getContext()
        
        do {
            try context.save()
            //**
            let fetch = NSFetchRequest<DGeoData>(entityName: "DGeoData") //should sort this by date
            let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
            fetch.sortDescriptors = [sortDescriptor ]
            do {
                let geoResults = try context.fetch(fetch)
                
                if  geoResults.count > 0 {
                    var archive:[[String]] = [[]]
                    let headerArray = ["participantID","currentWeatherTimestampString","taskUUID","apparentTemperature","apparentTemperatureMax","apparentTemperatureMin","cloudCover","dailySummary","dewPoint","humidity",
                                       "moonPhase","pressure","ozone","currentSummary","dailySummary","sunriseTimeString","sunsetTimeTimeString","temperature", "visibility","windspeed"]
                    //for index "index" and element "e" enumerate the elements of symptoms.
                    for (index, e) in geoResults.enumerated() {
                        let ar = [e.participantID, e.currentWeatherTimestampString, e.taskUUID, e.apparentTemperature, e.apparentTemperatureMax, e.apparentTemperatureMin,
                                  e.cloudCover, e.dailySummary, e.dewPoint, e.humidity,
                                  e.moonPhase, e.pressure, e.ozone, e.summary, e.dailySummary,
                                  e.sunriseTimeString, e.sunsetTimeTimeString, e.temperature, e.visibility, e.windSpeed]
                        archive.append(ar as! [String])
                        print("item for geospatial data: \(e.taskUUID)) \(index):\(e)")
                    }
                    archive.remove(at: 0)
                    archive.insert(headerArray, at: 0)
                    print(archive)
                    //upload array of arrays as a CSV file
                    let uploadFile = UploadApi()
                    uploadFile.writeAndUploadCSVToSharefile(forSymptomFocus: archive, "geospatial.csv")
                    
                }
                
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            //**
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    
}
