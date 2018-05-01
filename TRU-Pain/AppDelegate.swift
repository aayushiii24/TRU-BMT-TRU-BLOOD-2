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
import AlamofireNetworkActivityIndicator

// import GoogleSignIn
// import FirebaseInstanceID
// This was uploaded to iTunesConnect for testing on 4/22/2018. Might get rejected for remote notification stuff.

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Set up the style and color of the common UI elements
        
        /*Firebase*/
        FirebaseApp.configure()
        
        NetworkActivityIndicatorManager.shared.isEnabled = true
        
        
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
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: Colors.careKitRed.color], for:.selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: Colors.careKitRed.color], for:.normal)
        UITableViewCell.appearance().tintColor = Colors.careKitRed.color
    }
}

