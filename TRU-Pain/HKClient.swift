//
//  HKClient.swift
//  TRU-BMT
//
//  Created by Jude on 4/13/19.
//  Copyright © 2019 scdi. All rights reserved.
//

//
//  HKClient.swift
//  TRU-Pain
//
//  Created by jonas002 on 6/3/18.
//  Copyright © 2018 scdi. All rights reserved.
//
//
//  HKClient.swift
//  HKTest
import UIKit
import HealthKit

class HKClient : NSObject {
    
    var isSharingEnabled: Bool = false
    let healthKitStore:HKHealthStore? = HKHealthStore()
    let glucoseType : HKObjectType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodGlucose)!
    
    override init(){
        super.init()
    }
    
    func requestGlucosePermissions(authorizationCompleted: @escaping (_ success: Bool, _ error: NSError?)->Void) {
        
        let dataTypesToRead : Set<HKObjectType> = [ glucoseType ]
        
        if(!HKHealthStore.isHealthDataAvailable())
        {
            // let error = NSError(domain: "com.test.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey: "Healthkit is not available on this device"])
            self.isSharingEnabled = false
            return
        }
        
        self.healthKitStore?.requestAuthorization(toShare: nil, read: dataTypesToRead){(success, error) -> Void in
            self.isSharingEnabled = true
            //authorizationCompleted(success, error! as NSError)
            authorizationCompleted(success, error as NSError?)
        }
    }
    
    func getGlucoseSinceAnchor(anchor:HKQueryAnchor?, maxResults:uint, callback: ((_ source: HKClient, _ added: [String]?, _ deleted: [String]?, _ newAnchor: HKQueryAnchor?, _  error: NSError?)->Void)!){
        let queryEndDate = NSDate(timeIntervalSinceNow: TimeInterval(60.0 * 60.0 * 24))
        let queryStartDate = NSDate.distantPast
        let sampleType: HKSampleType = glucoseType as! HKSampleType
        let predicate: NSPredicate = HKAnchoredObjectQuery.predicateForSamples(withStart: queryStartDate, end: queryEndDate as Date, options: HKQueryOptions.strictStartDate)
        var hkAnchor: HKQueryAnchor;
        
        if(anchor != nil){
            hkAnchor = anchor!
        } else {
            hkAnchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
        }
        
        let onAnchorQueryResults : ((HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, NSError?) -> Void)! = {
            (query:HKAnchoredObjectQuery, addedObjects:[HKSample]?, deletedObjects:[HKDeletedObject]?, newAnchor:HKQueryAnchor?, nsError:NSError?) -> Void in
            
            var added = [String]()
            var deleted = [String]()
            
            if ((addedObjects?.count)! > 0){
                for obj in addedObjects! {
                    let quant = obj as? HKQuantitySample
                    if(quant?.uuid.uuidString != nil){
                        let val = Double( (quant?.quantity.doubleValue(for: HKUnit(from: "mg/dL")))! )
                        let msg : String = (quant?.uuid.uuidString)! + " " + String(val)
                        added.append(msg)
                    }
                }
            }
            
            if ((deletedObjects?.count)! > 0){
                for del in deletedObjects! {
                    let value : String = del.uuid.uuidString
                    deleted.append(value)
                }
            }
            
            //            if(callback != nil){
            //                callback(source:self, added: added, deleted: deleted, newAnchor: newAnchor, error: nsError)
            //            }
        }
        
        let anchoredQuery = HKAnchoredObjectQuery(type: sampleType, predicate: predicate, anchor: hkAnchor, limit: Int(maxResults), resultsHandler: onAnchorQueryResults as! (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void)
        healthKitStore?.execute(anchoredQuery)
        
    
    }
    
    let AnchorKey = "HKClientAnchorKey"
    func getAnchor() -> HKQueryAnchor? {
        let encoded = UserDefaults.standard.data(forKey: AnchorKey)
        if(encoded == nil){
            return nil
        }
        let anchor = NSKeyedUnarchiver.unarchiveObject(with: encoded!) as? HKQueryAnchor
        return anchor
    }
    
    func saveAnchor(anchor : HKQueryAnchor) {
        let encoded = NSKeyedArchiver.archivedData(withRootObject: anchor)
        UserDefaults.standard.setValue(encoded, forKey: AnchorKey)
        UserDefaults.standard.synchronize()
    }
    
}
