//
//  AppDelegate.swift
//  TRU-Pain
//
//  Created by jonas002 on 1/17/17.
//  Copyright © 2017 scdi. All rights reserved.
//


import Foundation
import UIKit
import CoreData
import UserNotifications
import Firebase
import HealthKit

//import AlamofireNetworkActivityIndicator

// import GoogleSignIn
// import FirebaseInstanceID
// This was uploaded to iTunesConnect for testing on 4/22/2018. Might get rejected for remote notification stuff.


typealias AccessRequestCallback = (_ success: Bool, _ error: NSError?) -> Void


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    let healthStore = HKHealthStore()
    //PARSE
    /*func saveInstallationObject(){
        if let installation = PFInstallation.current(){
            installation.saveInBackground {
                (success: Bool, error: Error?) in
                if (success) {
                    print("You have successfully connected your app to Back4App!")
                } else {
                    if let myError = error{
                        print(myError.localizedDescription)
                    }else{
                        print("Uknown error")
                    }
                }
            }
        }
    }*/
    func uploadSamples(_ samples: [Any]?, fromElement i: Int, then completionHandler: HKObserverQueryCompletionHandler) {
        if samples?.count == i {
            return
        }
        let sample = samples![i] as? HKQuantitySample
        print("sample ---> \(String(describing: sample))")
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Set up the style and color of the common UI elements
        
        /*Firebase*/
        FirebaseApp.configure()
        
        //NetworkActivityIndicatorManager.shared.isEnabled = true
        
        
        /* PARSE
        // Parse.setApplicationId("63Ry4xAsQECdZPMFyC2rgB9euvpLnMpa1kjcDyh8", clientKey: "Gj4vDQI6AmWlaOwbZFuu3DNxPs9uQTWcEYmH5oqT") trupain
        // Parse.setApplicationId("q8S9b7qmUW5lCCtpSDUSN2pEATEhtctxIgsIy9z9", clientKey: "CG4CFXV7nUhzK8nszWl0gRGXcSQ1b1trerlCssBg") trubmt
        
        Parse.enableLocalDatastore()
        let configuration = ParseClientConfiguration {
            $0.applicationId = "63Ry4xAsQECdZPMFyC2rgB9euvpLnMpa1kjcDyh8"
            $0.clientKey = "Gj4vDQI6AmWlaOwbZFuu3DNxPs9uQTWcEYmH5oqT"
            $0.server = "https//parseapi.back4app.com"
        }
        
        Parse.initialize(with: configuration)
        saveInstallationObject()
       */
        
        
        customizeUIStyle()
        
        //MR Coredata Stack
        MagicalRecord.setupCoreDataStack(withAutoMigratingSqliteStoreNamed: ".TRU-Pain")
        
        if #available(iOS 10.0, *) {
            let authOptions : UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_,_ in })
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            // For iOS 10 data message (sent via FCM)
			//            FIRMessaging.messaging().remoteMessageDelegate = self
            
        }
        //self.getRecentSteps()
        if #available(iOS 11.0, *) {
            self.requestAccessWithCompletion()
        } else {
            // Fallback on earlier versions
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
       
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }
    
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: ".TRU-pain")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        guard let context = NSManagedObjectContext.default() else {return}
        context.saveToPersistentStoreAndWait()
    }

    
    //HEALTHKIT STUFF
    @available(iOS 11.0, *)
    func dataTypesToRead() -> Set<HKObjectType> {
        return Set(arrayLiteral:
//            HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
                   HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
                   HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
                   HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!,
                   HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
                   HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
                   HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.restingHeartRate)!,
                   HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.walkingHeartRateAverage)!,
                   HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRateVariabilitySDNN)!,
                   HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.basalEnergyBurned)!,
                   HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
                   HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!,
                   HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.oxygenSaturation)!
//                   HKObjectType.workoutType()
        )
    }
    
    func dataTypesToWrite() -> Set<HKSampleType> {
        return Set(arrayLiteral:
            //HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
            //HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!,
                   HKObjectType.workoutType()
        )
    }
    
    @available(iOS 11.0, *)
    func queryForUpdates(type: HKObjectType) {
        switch type {
//        case HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!:
//            debugPrint("HKCharacteristicTypeIdentifierDateOfBirth")
        case HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!:
            debugPrint("HKCharacteristicTypeIdentifier.biologicalSex")
        case HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!:
            debugPrint("HKQuantityTypeIdentifier.heartRate")
        case HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRateVariabilitySDNN)!:
            debugPrint("HKQuantityTypeIdentifier.heartRate")
        case HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.restingHeartRate)!:
            debugPrint("HKQuantityTypeIdentifier.restingHeartRate")
        case HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.walkingHeartRateAverage)!:
            debugPrint("HKQuantityTypeIdentifier.walkingHeartRateAverage")
        case HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMassIndex)!:
            debugPrint("HKQuantityTypeIdentifier.bodyMassIndex")
        case HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!:
            debugPrint("HKQuantityTypeIdentifier.bodyMass")
        case HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!:
            debugPrint("HKQuantityTypeIdentifier.height")
        case HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!:
            debugPrint("HKQuantityTypeIdentifier.stepCount")
        case is HKWorkoutType:
            debugPrint("HKWorkoutType")
        default: debugPrint("Unhandled HKObjectType: \(type)")
        }
        
    }
    
   /* func getRecentSteps()  {
        if HKHealthStore.isHealthDataAvailable()
        {
            // Create the step count type.
            guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
                // This should never fail when using a defined constant.
                fatalError("*** Unable to get the step cout type ***")
            }
            
            
            var result : (anchor:HKQueryAnchor?, count:Int?) = (anchor:nil, count: -1)
            
            // Create the query.
            let query = HKAnchoredObjectQuery(type: stepCountType,
                                              predicate: nil,
                                              anchor: result.anchor,
                                              limit: HKObjectQueryNoLimit)
            { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
                
                guard let samples = samplesOrNil, let deletedObjects = deletedObjectsOrNil else {
                    // Handle the error here.
                    fatalError("*** An error occurred during the initial query: \(errorOrNil!.localizedDescription) ***")
                }
                
                result.anchor = newAnchor
                
                for stepCountSample in samples {
                    // Process the new step count samples here.
                    print("for stepCountSample in samples \(stepCountSample)")
                }
                
                for deletedStepCountSamples in deletedObjects {
                    // Process the deleted step count samples here.
                    print("for deletedStepCountSamples in deletedObjects \(deletedStepCountSamples)")
                }
            }
            
            
            // Optionally, add an update handler.
            query.updateHandler = { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
                
                guard let samples = samplesOrNil, let deletedObjects = deletedObjectsOrNil else {
                    // Handle the error here.
                    fatalError("*** An error occurred during an update: \(errorOrNil!.localizedDescription) ***")
                }
                
                result.anchor = newAnchor
                
                for stepCountSample in samples {
                    // Process the step counts from the update here.
                    print("for stepCountSample in samples 2.  \(stepCountSample)")
                }
                
                for deletedStepCountSamples in deletedObjects {
                    // Process the deleted step count smaples from the update here.
                    print("for deletedStepCountSamples in deletedObjects 2. \(deletedStepCountSamples)")
                }
            }
            
            // Run the query.
            healthStore.execute(query)
        }
    }*/
    
    func setUpBackgroundDeliveryForDataTypes(types: Set<HKObjectType>) {
        for type in types {
            guard let sampleType = type as? HKSampleType else { print("ERROR: \(type) is not an HKSampleType"); continue }
            let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { (query, completionHandler, anError) in
                debugPrint("observer query update handler called for type \(type), error: \(String(describing: anError))")
                if anError == nil {
                    if #available(iOS 11.0, *) {
                        
                        self.queryForUpdates(type: type)
                    } else {
                        // Fallback on earlier versions
                    }
                }
                completionHandler()
            }
            
            healthStore.execute(query)
            healthStore.enableBackgroundDelivery(for: type, frequency: .immediate) { (success, error) in
                debugPrint("enableBackgroundDeliveryForType handler called for \(type) - success: \(success), error: \(String(describing: error))")
                //self.updateSteps(completionHandler: ({
                //
                //                }))
            }
        }
        
    }
    
    @available(iOS 11.0, *)
    func requestAccessWithCompletion() {
        healthStore.requestAuthorization(toShare: nil, read: dataTypesToRead()) { (success, error) -> Void in
            if success {
                print("success")
                self.setUpBackgroundDeliveryForDataTypes(types:self.dataTypesToRead())
                //                DispatchQueue.main.async() {
                //                    completion(success, error as NSError?)
                //
                //                }
            } else {
                print("failure")
            }
            if let error = error { print(error) }
        }
    }

}
extension AppDelegate {
    func customizeUIStyle() {
        let standardDefaults = UserDefaults.standard
        if standardDefaults.object(forKey: "ORKSampleFirstRun") == nil {
            let keychain = KeychainSwift()
            keychain.delete("username_TRU-BLOOD")
            keychain.delete("password_TRU-BLOOD")
            standardDefaults.setValue("ORKSampleFirstRun", forKey: "ORKSampleFirstRun")
        }
        print("nothing")
        
        //UI Color scheme
        UINavigationBar.appearance().tintColor = Colors.careKitRed.color
        UITabBar.appearance().tintColor = Colors.careKitRed.color
        UITabBarItem.appearance().setTitleTextAttributes(convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): Colors.careKitRed.color]), for:.selected)
        UITabBarItem.appearance().setTitleTextAttributes(convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): Colors.careKitRed.color]), for:.normal)
        UITableViewCell.appearance().tintColor = Colors.careKitRed.color
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
