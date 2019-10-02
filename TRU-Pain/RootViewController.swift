/*
 Copyright (c) 2016, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit
import CareKit
import ResearchKit
//import WatchConnectivity
import CoreData
import Alamofire
import Foundation
import CoreLocation
import UserNotifications
import DefaultsKit
import Firebase


//enum ReadDataExceptions : Error {
//    case moreThanOneRecordCameBack
//}


class RootViewController: UITabBarController {
    // MARK: Properties
    
    //FIREBASE//
    var db: Firestore!
    
    fileprivate let sampleData: SampleData
    //fileprivate let vopamData: VOPAMSampleData //VOPAM:
    
    fileprivate let storeManager = CarePlanStoreManager.sharedCarePlanStoreManager
    
    fileprivate var careCardViewController: OCKCareCardViewController!
    
    //VOPAM:
    //fileprivate var vopamCardViewController: OCKCareCardViewController!
    
    fileprivate var symptomTrackerViewController: OCKSymptomTrackerViewController!
    
    fileprivate var insightsViewController: OCKInsightsViewController!
    
    fileprivate var connectViewController: OCKConnectViewController!
    
    
     private var stepsViewController:UIViewController!
    
    
    //fileprivate var watchManager: WatchConnectivityManager?
    
    private var videoRecordingViewController:UIViewController!
    private var locationViewController:UIViewController!
    private let dataManager = DataManager(baseURL: API.AuthenticatedBaseURL)
    
    //add:report
    fileprivate var insightChart: OCKBarChart? = nil
    
    
    var container: NSPersistentContainer!
    var isFirstUpdate:Bool = false //CORE LOCATION
    var taskUUID: UUID?
    var userEmail:String = ""
    
    let listDataManager = ListDataManager()
    
    
    public lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        return manager
    }()
    
    // MARK: Healthstore_ prep
    let healthStore: HKHealthStore = HKHealthStore()
    let heartRateUnit:HKUnit = HKUnit(from: "count/min")
    let heartRateType:HKQuantityType   = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    var heartRateQuery:HKQuery?
    var activityArray:[[String]]?
    var sleepActivityArray:[[String]]?
    
    
    
    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        sampleData = SampleData(carePlanStore: storeManager.store)
        
        
        super.init(coder: aDecoder)
        
        /*
         var geo: [DGeoData]!
         geo = DGeoData.mr_findAll() as! [DGeoData]
         if geo.count > 0 {
         for (index, element) in geo.enumerated() {
         print("item geo: \(element.taskUUID)) \(index):\(element)")
         }
         }
         
         var symptoms: [DSymptomFocus]!
         symptoms = DSymptomFocus.mr_findAll() as! [DSymptomFocus]
         if symptoms.count > 0 {
         for (index, element) in symptoms.enumerated() {
         print("item: \(element.name)) \(index):\(element)")
         }
         }
         */
        
        
        /*
         var health: [DGeneralHealth]!
         health = DGeneralHealth.mr_findAll() as! [DGeneralHealth]
         if health.count > 0 {
         for (index, element) in health.enumerated() {
         print("item: \(element.taskRunUUID)) \(index):\(element)")
         }
         }
         var stool: [DStool]!
         stool = DStool.mr_findAll() as! [DStool]
         if stool.count > 0 {
         for (index, element) in stool.enumerated() {
         print("item: \(element.taskRunUUID)) \(index):\(element)")
         }
         }
         var temperature: [DTemperature]!
         temperature = DTemperature.mr_findAll() as! [DTemperature]
         if temperature.count > 0 {
         for (index, element) in temperature.enumerated() {
         print("item: \(element.taskRunUUID)) \(index):\(element)")
         }
         }
         */
        //self.viewSymptoms()
        //self.findCurrentLocation(taskID: "viewLoad") //CORE LOCATION
//        let keychain = KeychainSwift()
//        
//        let defaults = UserDefaults()
//        defaults.setValue("NO", forKey: "hasPasswordForProfile")
        
        
        let defaults = UserDefaults()
        defaults.setValue("NO", forKey: "hasPasswordForProfile")
        
        
        careCardViewController = createCareCardViewController()
        symptomTrackerViewController = createSymptomTrackerViewController()
        insightsViewController = createInsightsViewController()
        connectViewController = createConnectViewController()
        //stepsViewController = createStepsViewController()
        
        
        self.viewControllers = [
            UINavigationController(rootViewController: careCardViewController),
            UINavigationController(rootViewController: symptomTrackerViewController),
            UINavigationController(rootViewController: insightsViewController),
            UINavigationController(rootViewController: connectViewController),
           // UINavigationController(rootViewController: stepsViewController),
        ]
        storeManager.delegate = self
        //watchManager = WatchConnectivityManager(withStore: storeManager.store)
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        UITabBarItem.appearance().setTitleTextAttributes(convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.gray]), for: .normal)
        //Getting data from the store
        //self.viewSymptoms()
        
        // [START FIREBASE setup]
       // let settings = FirestoreSettings()
        
       // Firestore.firestore().settings = settings
        // [END setup]
        self.db = Firestore.firestore()
         
        self.requestAuthorization()
        
    }
    
    // MARK: Healthstore_ request for authorization and 10 day range upload
    func requestAuthorization()
    {
       print("requesting authorization to read heart data")
        let readingTypes:Set = Set( [heartRateType] )
        
        //writing
        let writingTypes:Set = Set( [heartRateType] )
        
        //auth request
        healthStore.requestAuthorization(toShare: writingTypes, read: readingTypes) { (success, error) -> Void in
            
            if error != nil
            {
                print("error getting data \(error?.localizedDescription)")
            }
            else if success
            {
                var daysOfData = "-10" //self.readHeartRateData()
                let keychain = KeychainSwift()
                if keychain.get("DaysOfData") != nil {
                    daysOfData = keychain.get("DaysOfData")!
                }
                    
//                let defaults = UserDefaults.standard
//                let daysOfData = defaults.value(forKey: "daysOfData") as? String
               print("daysofdata \(String(describing: daysOfData))")
                
                let todayDate = Date() //
                let calendar = Calendar.current
                var ninetyDaysAgoDate: Date?
                ninetyDaysAgoDate = calendar.date(byAdding: .day,
                                                  value: Int(daysOfData)!,
                                                  to: todayDate)
                
                let x = UploadsViewController()
                x.getHKHeartRateData(ninetyDaysAgoDate!)
                x.getHKStepData(ninetyDaysAgoDate!)
                x.getHKHeartRateVariabilityData(ninetyDaysAgoDate!)
                self.retrieveSleepAnalysis(startDate: ninetyDaysAgoDate!)
                
                keychain.set("-10", forKey: "DaysOfData")
                
            }
        }//eo-request
    }
    
    


    
//    /*used only for testing, prints heart rate info */
//    private func printHeartRateInfo(results:[HKSample]?)
//    {
//        for(var iter = 0 ; iter < results!.count; iter++)
//        {
//            guard let currData:HKQuantitySample = results![iter] as? HKQuantitySample else { return }
//
//            print("[\(iter)]")
//            print("Heart Rate: \(currData.quantity.doubleValueForUnit(heartRateUnit))")
//            print("quantityType: \(currData.quantityType)")
//            print("Start Date: \(currData.startDate)")
//            print("End Date: \(currData.endDate)")
//            print("Metadata: \(currData.metadata)")
//            print("UUID: \(currData.UUID)")
//            print("Source: \(currData.sourceRevision)")
//            print("Device: \(currData.device)")
//            print("---------------------------------\n")
//        }//eofl
//    }//eom
    
    
    
    // MARK: Convenience
    private func createVideoRecordingViewController() -> UIViewController {
        let vc = UIStoryboard(name: "MainStoryboard", bundle: nil)
        let viewController = vc.instantiateViewController(withIdentifier: "videoRecorderViewControllerSB")
        let homeUIBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear.png"), style: .plain, target: self, action: #selector(RootViewController.toHome))
        viewController.navigationItem.leftBarButtonItem  = homeUIBarButtonItem
        homeUIBarButtonItem.tintColor = Colors.careKitRed.color
        // Setup the controller's title and tab bar item
        viewController.title = NSLocalizedString("Media", comment: "")
        viewController.tabBarItem = UITabBarItem(title: viewController.title, image: UIImage(named:"film-clap-board"), selectedImage: UIImage(named: "film-clap-board"))
        
        return viewController
    }
    
    private func createLocationViewController() -> UIViewController {
        let vc = UIStoryboard(name: "MainStoryboard", bundle: nil)
        let viewController = vc.instantiateViewController(withIdentifier: "locationStoryBoard")
        let homeUIBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear.png"), style: .plain, target: self, action: #selector(RootViewController.toHome))
        viewController.navigationItem.leftBarButtonItem  = homeUIBarButtonItem
        homeUIBarButtonItem.tintColor = Colors.careKitRed.color
        // Setup the controller's title and tab bar item
        viewController.title = NSLocalizedString("Location", comment: "")
        viewController.tabBarItem = UITabBarItem(title: viewController.title, image: UIImage(named:"video"), selectedImage: UIImage(named: "video"))
        
        return viewController
    }
    
    
    fileprivate func createCareCardViewController() -> OCKCareCardViewController {
        let viewController = OCKCareCardViewController(carePlanStore: storeManager.store)
        let homeUIBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear.png"), style: .plain, target: self, action: #selector(RootViewController.toHome))
        viewController.navigationItem.leftBarButtonItem  = homeUIBarButtonItem
        //viewController.maskImageTintColor = Colors.careKitRed.color
        homeUIBarButtonItem.tintColor = Colors.careKitRed.color
        // Setup the controller's title and tab bar item
        viewController.title = NSLocalizedString("Diary", comment: "")
        viewController.isSorted = false
//        viewController.isGrouped = false
        
        viewController.tabBarItem = UITabBarItem(title: viewController.title, image: UIImage(named:"carecard"), selectedImage: UIImage(named: "carecard-filled"))
        
        return viewController
    }
    
    fileprivate func createVOPAMCardViewController() -> OCKCareCardViewController {
        let viewController = OCKCareCardViewController(carePlanStore: storeManager.store)
        let homeUIBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear.png"), style: .plain, target: self, action: #selector(RootViewController.toHome))
        viewController.navigationItem.leftBarButtonItem  = homeUIBarButtonItem
        //viewController.maskImageTintColor = Colors.careKitRed.color
        homeUIBarButtonItem.tintColor = Colors.careKitRed.color
        // Setup the controller's title and tab bar item
        viewController.title = NSLocalizedString("VOPAM", comment: "")
        
        viewController.tabBarItem = UITabBarItem(title: viewController.title, image: UIImage(named:"carecard"), selectedImage: UIImage(named: "carecard-filled"))
        
        return viewController
    }
    
    
    fileprivate func createSymptomTrackerViewController() -> OCKSymptomTrackerViewController {
        let viewController = OCKSymptomTrackerViewController(carePlanStore: storeManager.store)
        viewController.delegate = self
        let homeUIBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear.png"), style: .plain, target: self, action: #selector(RootViewController.toHome))
        viewController.navigationItem.leftBarButtonItem  = homeUIBarButtonItem
        homeUIBarButtonItem.tintColor = Colors.careKitRed.color
        //viewController.progressRingTintColor = Colors.careKitRed.color
        viewController.navigationItem.rightBarButtonItem?.tintColor = Colors.careKitRed.color
        
        // Setup the controller's title and tab bar item
        viewController.title = NSLocalizedString("Health", comment: "")
        viewController.tabBarItem = UITabBarItem(title: viewController.title, image: UIImage(named:"symptoms"), selectedImage: UIImage(named: "symptoms-filled"))
        viewController.isSorted = false
        viewController.isGrouped = false
        return viewController
    }
    
    private func createStepsViewController() -> UIViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil)
        let viewController = vc.instantiateViewController(withIdentifier: "StepsViewControllerSB")
        let homeUIBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear.png"), style: .plain, target: self, action: #selector(RootViewController.toHome))
        viewController.navigationItem.leftBarButtonItem  = homeUIBarButtonItem
        homeUIBarButtonItem.tintColor = Colors.careKitRed.color
        // Setup the controller's title and tab bar item
        viewController.title = NSLocalizedString("Steps", comment: "")
        viewController.tabBarItem = UITabBarItem(title: viewController.title, image: UIImage(named:"_0002_icon_SingleHead"), selectedImage: UIImage(named: "_0002_icon_SingleHead"))
        
        
        return viewController
    }
    
    fileprivate func createConnectViewController() -> OCKConnectViewController {
        
        let defaults = UserDefaults.standard
        let studyName = defaults.value(forKey: "Study") as? String
        //let studySite = defaults.get("Institution")
        
//        let study = (studySite?.lowercased())!+(studyName?.lowercased())!
        let study = studyName?.lowercased()
        
        var contacts = [OCKContact]()
        print("CONTACT TO CHOOSE \(String(describing: study))")
        contacts = sampleData.contactsDukeBMT
        
        
        print("CONTACTS chosen \(contacts)")
        let viewController = OCKConnectViewController(contacts:contacts)
        viewController.delegate = self
        let homeUIBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear.png"), style: .plain, target: self, action: #selector(RootViewController.toHome))
        viewController.navigationItem.leftBarButtonItem  = homeUIBarButtonItem
        homeUIBarButtonItem.tintColor = Colors.careKitRed.color
        // Setup the controller's title and tab bar item
        viewController.title = NSLocalizedString("Connect", comment: "")
        viewController.tabBarItem = UITabBarItem(title: viewController.title, image: UIImage(named:"connect"), selectedImage: UIImage(named: "connect-filled"))
        //        self.highlightIcon()
        return viewController
    }
    
    
    fileprivate func createInsightsViewController() -> OCKInsightsViewController {
        // Create an `OCKInsightsViewController` with sample data.
        //let headerTitle = NSLocalizedString("Chart", comment: "")
        //let viewController = OCKInsightsViewController(insightItems: storeManager.insights, headerTitle: headerTitle, headerSubtitle: "")
        
        let activityType1: ActivityType = .generalHealth
        let widget1 = OCKPatientWidget.defaultWidget(withActivityIdentifier: activityType1.rawValue, tintColor: OCKColor.red())
        let viewController = OCKInsightsViewController(insightItems: storeManager.insights, patientWidgets: [widget1], thresholds: [activityType1.rawValue], store:storeManager.store)
        
        let homeUIBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear.png"), style: .plain, target: self, action: #selector(RootViewController.toHome))
        viewController.navigationItem.leftBarButtonItem  = homeUIBarButtonItem
        
        homeUIBarButtonItem.tintColor = Colors.careKitRed.color
        // Setup the controller's title and tab bar item
        viewController.title = NSLocalizedString("Insights", comment: "")
        viewController.tabBarItem = UITabBarItem(title: viewController.title, image: UIImage(named:"insights"), selectedImage: UIImage(named: "insights-filled"))
        print("storemanager insight \(storeManager.insights)")
        return viewController
    }
    
    
    func highlightIcon()  {
        self.selectedIndex = 0
        
        self.tabBar.selectedItem = tabBar.items![1]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)  {
        print("0")
        
    }

    @objc func toHome() -> () {
        performSegue(withIdentifier: "ckReturnHome", sender: nil)
        
        //MagicalRecord.save({ (context) in  })
        
    }
    
    func appMode(email:String) -> String {
        var mode:String = "Production"
        
        let itemsArray = ["AppleUser@icloud.com", "sicklecell@me.com", "trupain@icloud.com", "trupain000@icloud.com", "trupbmt000@icloud.com", "bmtckstudy000@icloud.com"]
        let filteredStrings = itemsArray.filter({(item: String) -> Bool in
            let stringMatch = item.lowercased().range(of: email)
            print("stringMatch \(String(describing: stringMatch))")
            return stringMatch != nil ? true : false
        })
        
        if filteredStrings.count == 0    {
            mode = "Production"
            print("app mode is Production")
        } else {
            mode = "Testing"
            print("app mode is Test")
        }
        return mode
    }
    
}



extension RootViewController: OCKSymptomTrackerViewControllerDelegate {
    
    /// Called when the user taps an assessment on the `OCKSymptomTrackerViewController`.
    func symptomTrackerViewController(_ viewController: OCKSymptomTrackerViewController, didSelectRowWithAssessmentEvent assessmentEvent: OCKCarePlanEvent) {
        // Lookup the assessment the row represents.
        guard let activityType = ActivityType(rawValue: assessmentEvent.activity.identifier) else { return }
        guard let sampleAssessment = sampleData.activityWithType(activityType) as? Assessment else { return }
        
        /*
         Check if we should show a task for the selected assessment event
         based on its state.
         */
        guard assessmentEvent.state == .initial ||
            assessmentEvent.state == .notCompleted ||
            (assessmentEvent.state == .completed && assessmentEvent.activity.resultResettable) else { return }
        
        // Show an `ORKTaskViewController` for the assessment's task.
        let taskViewController = ORKTaskViewController(task: sampleAssessment.task(), taskRun: nil)
        taskViewController.delegate = self
        
        present(taskViewController, animated: true, completion: nil)
    }
}



extension RootViewController: ORKTaskViewControllerDelegate {
    
    func getContext () -> NSManagedObjectContext {
        let context = NSManagedObjectContext.default()
        return context!
    }
    
    
    //
    //    func saveContext() throws{
    //        let appDelegate = UIApplication.shared.delegate as! AppDelegate
    //        let context = appDelegate.persistentContainer.viewContext
    //        if context.hasChanges {
    //            try context.save()
    //        }
    //    }
    
        func viewSymptoms()  {
            // Initialize Fetch Request
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
    
            // Create Entity Description
            let entityDescription = NSEntityDescription.entity(forEntityName: "CKSymptom", in: getContext())
    
            // Configure Fetch Request
            fetchRequest.entity = entityDescription
    
            do {
                let result = try getContext().fetch(fetchRequest)
                print(result)
    
            } catch {
                let fetchError = error as NSError
                print(fetchError)
            }
            do {
                let result = try getContext().fetch(fetchRequest)
    
                if (result.count > 0) {
                    let person = result[0] as! NSManagedObject
    
                    print("1 - \(person)")
    
                    if let first = person.value(forKey: "status"), let last = person.value(forKey: "triggers") {
                        print("\(first) \(last)")
                    }
    
                    print("2 - \(person)")
                }
    
            } catch {
                let fetchError = error as NSError
                print(fetchError)
            }
    
    
    
//            var symptoms = [SymptomInFocus]()
//            symptoms = SymptomInFocus.mr_findAll() as! [SymptomInFocus]
//            print("those are my symptoms \(symptoms)")
    
    }
    
    
    
    //CORE LOCATION
    func findCurrentLocation(taskID:String) {
        self.isFirstUpdate = true;
        locationManager.startUpdatingLocation()
        print("finding current location")
        print("finding current location \(taskID)")
    }
    
    //CORE LOCATION
    func findCurrentUserLocation(taskID:String) {
        self.isFirstUpdate = true;
        locationManager.startUpdatingLocation()
        print("finding current location")
        print("finding current location \(taskID)")
    }
    
    
    
    //MARK: retrieve sleep data
    @objc func retrieveSleepAnalysis(startDate:Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        //let standardDefaults = UserDefaults.standard
        
        self.sleepActivityArray = [[""]]
        self.sleepActivityArray?.remove(at: 0)
        let endDate = NSDate()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate as Date, options: .strictEndDate)
        print("get sleep data")
        // first, we define the object type we want
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            
            // Use a sortDescriptor to get the recent data first
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            // we create our query with a block completion to execute
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 365, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                
                if error != nil {
                    print("can't get any sleep data")
                    return
                    
                }
                
                if let result = tmpResult {
                    let fx = UploadsViewController()
                    // do something with my data
                    /*
                     NSArray *arHeader = @[
                     "deviceName",
                     "userName",
                     "StartDate",
                     "EndDate",
                     "inBedOrAsleep",
                     "AppName",
                     "DeviceDescription",
                     "iOSVersion",
                     "sampleDeviceName",
                     "sampleDeviceHardwareVersion",
                     "sampleDeviceModel",
                     "sampleUUID",
                     "sampleSourceRevisionDescription"
                     ];*/
                    let arHeader  = [
                        "deviceName",
                        "userName",
                        "StartDate",
                        "EndDate",
                        "inBedOrAsleep",
                        "AppName",
                        "DeviceDescription",
                        "iOSVersion",
                        "sampleDeviceName",
                        "sampleDeviceHardwareVersion",
                        "sampleDeviceModel",
                        "sampleUUID",
                        "sampleSourceRevisionDescription"
                    ]
                    for item in result {
                        var ar:[String]?
                        var dictionary:[String:Any]?
                        
                        if let sample = item as? HKCategorySample {
                            let value = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "InBed" : "Asleep"
                            
                            var userName  = fx.userName()
                            if userName == ""
                            {
                                userName = "AppleUser@icloud.com"
                                
                            }
                            
                            var sampleDeviceName = String(describing:sample.device?.name)
                            if sampleDeviceName == "" {sampleDeviceName = "-99"}
                            
                            var sampleDeviceHardwareVersion = String(describing:sample.device?.hardwareVersion)
                            if sampleDeviceHardwareVersion == "" {sampleDeviceHardwareVersion = "-99"}
                            
                            var sampleDeviceModel = String(describing:sample.device?.model)
                            if sampleDeviceModel == "" {sampleDeviceModel = "-99"}
                            
                            var sampleUUID = String(describing:sample.uuid.uuidString)
                            if sampleUUID == "" {sampleUUID = "-99"}
                            
                            var sampleSourceRevisionDescription = String(describing:sample.sourceRevision.source.description)
                            if sampleSourceRevisionDescription == "" {sampleSourceRevisionDescription = "-99"}
                            
                            
                            
                            ar = [self.removeSpecialCharsFromString(text: UIDevice.current.name),
                                  userName,
                                  formatter.string(from:sample.startDate),
                                  formatter.string(from:sample.endDate),String(describing:value),
                                  self.removeSpecialCharsFromString(text: sample.sourceRevision.source.name),
                                  self.removeSpecialCharsFromString(text: HKDevice.description()),
                                  sample.sourceRevision.version!,
                                  sampleDeviceName,
                                  sampleDeviceHardwareVersion,
                                  sampleDeviceModel,
                                  sampleUUID,
                                  sampleSourceRevisionDescription
                            ]
                            
                            let zipArHeader = zip(arHeader,ar!)
                            
                            
                            self.sleepActivityArray?.append(ar!)
                        }
                    }
                    
                    
                        fx.getHKSleepData(self.sleepActivityArray!)
                        
                    
                }
            }
            
            self.healthStore.execute(query)
        }
    }
    
    
    
    
    func removeSpecialCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-*=(),.:!_[]".characters)
        return String(text.characters.filter {okayChars.contains($0) })
    }
    
    /// Called with then user completes a presented `ORKTaskViewController`.
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        
        
        
        defer {
            dismiss(animated: true, completion: nil)
        }
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "yyyy-MM-dd"
        
        let dayOfWeekFormatter = DateFormatter()
        dayOfWeekFormatter.dateFormat = "EEEE"
        
        let monthOfYearDateFormatter = DateFormatter()
        monthOfYearDateFormatter.dateFormat = "MMM"
        
        let yearOfEventDateFormatter = DateFormatter()
        yearOfEventDateFormatter.dateFormat = "yyyy"
        
        // Make sure the reason the task controller finished is that it was completed.
        guard reason == .completed else { return }
        
        
        guard let event = symptomTrackerViewController.lastSelectedAssessmentEvent,
            let activityType = ActivityType(rawValue: event.activity.identifier),
            let sampleAssessment = sampleData.activityWithType(activityType) as? Assessment else { return }
        _ = sampleAssessment.buildResultForCarePlanEvent(event, taskResult: taskViewController.result)
        let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)
        let components = event.date
        let date = calendar?.date(from: components)
        
        var newDateString:String = ""
        newDateString = dayFormatter.string(from: date!)
        print("newDateString 463: \(newDateString)")
        
        
        if let results = taskViewController.result.results as? [ORKStepResult] {
            
            //yyyy-MM-dd'T'HH:mm:ssZ -- 2016-12-10T18:58:03-0500
            
            //Start SymptomFocus
            if taskViewController.result.identifier == "symptomTracker" {
                var dSymptomFocus:DSymptomFocus!
                let keychain = KeychainSwift()
                dSymptomFocus = listDataManager.createSymptomFocus(entityName: "DSymptomFocus")
                
                if let username = keychain.get("username_TRU-BLOOD") {
                    dSymptomFocus.participantID =  username
                }
                dSymptomFocus.taskRunUUID = String(describing: taskViewController.result.taskRunUUID as UUID)
                dSymptomFocus.timestamp = taskViewController.result.endDate as NSDate? as Date?
                dSymptomFocus.timestampString = formatter.string(from: taskViewController.result.endDate)
                dSymptomFocus.timestampEnd = taskViewController.result.endDate as NSDate? as Date?
                dSymptomFocus.timestampEndString = formatter.string(from: taskViewController.result.endDate)
                dSymptomFocus.dayString = dayFormatter.string(from: date!)
                
                
                var symptomsTracked = [String: String]()
                symptomsTracked["dataOfType"] = "Symptom"
                symptomsTracked["taskRunUUID"] = String(describing: taskViewController.result.taskRunUUID as UUID)
                symptomsTracked["dataEntryStartingTime"] = formatter.string(from: taskViewController.result.startDate)
                symptomsTracked["dataEntryEndingTime"] = formatter.string(from: taskViewController.result.endDate)
                
                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    print("version of app \(version)")
                    symptomsTracked["appVersion"] = version
                }
                if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                    print("version of app \(build)")
                    symptomsTracked["appBuild"] = build
                }
                
                print("we have focus symptom focus")
                for stepResult: ORKStepResult in results {
                    print(stepResult.startDate)
                    print(stepResult.endDate)
                    print(stepResult.identifier)
                    
                    for result in stepResult.results! {
                        print("----- > triggers result identifier, start date and end date \n")
                        print(result.identifier)
                        print(result.startDate)
                        print(result.endDate)
                        
                        
                        if let questionResult = result as? ORKQuestionResult {

                            
                            //var bodyLocationsString: String = ""
                            if questionResult.identifier == "symptom_focus" {
                                let array = questionResult.answer as! NSArray
                                //print("questionResult.answer to save \(array) and first object\(String(describing: array.firstObject))")
                                dSymptomFocus.name = array.firstObject as! String?
                                symptomsTracked["symptom"] = array.firstObject as! String?
                            }
                            
                            if questionResult.identifier == "symptomTracker_eventTimeStamp" {
                                print("symptomTracker_eventTimeStamp 508" )
                                if let symptomDate = questionResult.answer! as? NSDate {
                                    
                                    //this is the today date but not necessarily the date for which this person is entering the data
                                    //we will will replace that date with the date the person is entering the data but keep the time that the perrson want to tenter the data for
                                    print("date. \(symptomDate) 0")
                                    dSymptomFocus.date = symptomDate as Date
                                    var aString:String = ""
                                    aString = formatter.string(from: symptomDate as Date)
                                    let mystring = aString.dropFirst(10)
                                    let realDateTimeString = newDateString+mystring
                                    
                                    dSymptomFocus.dateString = realDateTimeString//formatter.string(from: date as Date)
                                    symptomsTracked["dateOfEvent"] = dayFormatter.string(from: symptomDate as Date)
                                    symptomsTracked["dayOfWeekOfEvent"] = dayOfWeekFormatter.string(from: symptomDate as Date)
                                    symptomsTracked["monthOfYearOfEvent"] = monthOfYearDateFormatter.string(from: symptomDate as Date)
                                    symptomsTracked["yearOfEvent"] = yearOfEventDateFormatter.string(from: symptomDate as Date)
                                    
                                    print("dateString. \(String(describing: dSymptomFocus.dateString)) 0") //this the date the user reports as the event date and time.
                                } else {
                                    print("we did not enter a date so we could use the current date : \(Date())")
                                    symptomsTracked["forDateString"] = "NA"
                                }
                            }
                            
                            if questionResult.identifier == "symptom_intensity_level" {
                                let measure = (questionResult.answer! as? NSNumber)?.stringValue
                                print("intensityLevel = \(String(describing: measure))")
                                //                            dSymptomFocus.intensity = measure
                                let x = (questionResult.answer! as? Double)
                                let xRounded = x!.roundTo(places: 1)
                                
                                dSymptomFocus.intensity = String(xRounded)
                                dSymptomFocus.metric = "outOf10"
                                
                                symptomsTracked["intensity"] = String(xRounded)
                                symptomsTracked["metric"] = "outOf10"
                                
                                
                            }
                            
                           
                            
                            if questionResult.identifier == "symptom_status" {
                                print("SymptomStatus 531")
                                if let array = questionResult.answer as? NSArray {
                                    print("questionResult.answer to save \(array) and first object\(String(describing: array.firstObject))")
                                    print("questionResult.answer.status to save \(String(describing: questionResult.answer))")
                                    //symptom.status = questionResult.answer as? String
                                    dSymptomFocus.status = array.firstObject as? String
                                    symptomsTracked["symptomStatus"] = array.firstObject as? String
                                }
                            }
                            
//                            if questionResult.identifier == "symptom_affected_body_locations" {
//                                guard let myArray = questionResult.answer as? NSArray, myArray.count >= 1 else {
//                                    print("String is nil or empty.")
//                                    dSymptomFocus.bodyLocations = "none"
//                                    //use return, break, continue, or throw
//                                    break
//                                }
//                                print("questionResult.answer has data in the array")
//                                let string = myArray.componentsJoined(by: ",") as String
//                                dSymptomFocus.bodyLocations = string
//
//                            }
//                            if questionResult.identifier == "other_locations" {
//                                print("other_locations answer ", String(describing:questionResult.answer))
//                                guard let string = questionResult.answer as? String, !string.isEmpty else {
//                                    dSymptomFocus.otherBodyLocations = "none"
//                                    break
//                                }
//
//                                dSymptomFocus.otherBodyLocations = string
//                                print(string)
//                                print("PPPaPP")
//                            }
                            
                            if questionResult.identifier == "other_interventions" {
                                //print("other_interventions answer \(String(describing: questionResult.answer))")
                                guard let string = questionResult.answer as? String, !string.isEmpty else {
                                    dSymptomFocus.otherInterventions = "none"
                                    symptomsTracked["otherInterventions"] = "none"
                                    break
                                }
                                
                                dSymptomFocus.otherInterventions = string
                                symptomsTracked["otherInterventions"] = string
                                print(string)
                                print("PPPsPP")
                                
                            }
//                            if questionResult.identifier == "other_triggers" {
//                                print("other_triggers answer \(String(describing: questionResult.answer)) \n")
//                                guard let string = questionResult.answer as? String, !string.isEmpty else {
//                                    dSymptomFocus.otherTriggers = "none"
//                                    break
//                                }
//
//                                dSymptomFocus.otherTriggers = string
//                                print(string)
//                                print("PPPPP")
//
//                            }
                            
                            if questionResult.identifier == "symptom_interventions" {
                                guard let array = questionResult.answer as? NSArray, array.count >= 1 else {
                                    print("intervention String is nil or empty.")
                                    dSymptomFocus.interventions = "none"
                                    break
                                }
                                let string = array.componentsJoined(by: ",") as String
                                dSymptomFocus.interventions = string
                            }
                            
//                            if questionResult.identifier == "symptom_triggers" {
//                                guard let array = questionResult.answer as? NSArray, array.count >= 1 else {
//                                    print("intervention String is nil or empty.")
//                                    dSymptomFocus.triggers = "none"
//                                    break
//                                }
//                                let string = array.componentsJoined(by: ",") as String
//                                dSymptomFocus.triggers = string
//                            }
                        }
                    }
                }
                let handle = Auth.auth().addStateDidChangeListener { (auth, user) in
                    if let user = user {
                        
                        let uid = user.uid
                        let email = user.email
                        //let photoURL = user.photoURL

                        symptomsTracked["userID"] = uid
                        symptomsTracked["userEmail"] = email
                        symptomsTracked["appMode"] = self.appMode(email: email!)
                        symptomsTracked["author_id"] = uid
                        
                        var ref: DocumentReference? = nil
                        ref = self.db.collection("symptoms").addDocument(data: symptomsTracked) { err in
                            if let err = err {
                                print("Error adding document: \(err)")
                            } else {
                                print("Document added with ID: \(ref!.documentID)")
                            }
                        }
                    }
                }
                
                
                //SAVE
                listDataManager.saveCareData()
                
                //Get an array of the rows in coredata to upload.
                let symptoms = listDataManager.findSymptomFocus(entityName: "DSymptomFocus") as [DSymptomFocus]
                if symptoms.count > 0 {
                    var archive:[[String]] = [[]]
                    let headerArray = ["participantID","dateString","taskRunUUID","name","intensity","metric","status", "interventions", "otherInterventions","interference","interferenceMetric","interference","interferenceMetric","timestampString","timestampEndString","dayString"]
                    
                    
                    //for index "index" and element "e" enumerate the elements of symptoms.
                    for (index, e) in symptoms.enumerated() {
                        let ar = [e.participantID, e.dateString, e.taskRunUUID, e.name, e.intensity, e.metric, e.status, e.interventions, e.otherInterventions,  e.timestampString, e.timestampEndString, e.dayString]
                        archive.append(ar as! [String])
                        
                        
                        print("item: \(e.name)) \(index):\(e)")
                    }
                    
                    
                    
                    
                    archive.remove(at: 0)
                    archive.insert(headerArray, at: 0)
                    print(archive)
                    //upload array of arrays as a CSV file
                    let uploadSymptomFocus = UploadApi()
                    uploadSymptomFocus.writeAndUploadCSVToSharefile(forSymptomFocus: archive, "symptomFocus.csv")
                    
                }
            }
            //END SymtomFocus
            
            //START Appetite
            if taskViewController.result.identifier == "appetite" {
                let carePlanResult = sampleAssessment.buildResultForCarePlanEvent(event, taskResult: taskViewController.result)
                var dAppetite: DAppetite!
                // PARSE var dailyMeals = PFObject(className:"Meals") //Jude:Add parse
                
                
                dAppetite = listDataManager.createDAppetite(entityName: "DAppetite") as DAppetite
                
                let keychain = KeychainSwift()
                if let username = keychain.get("username_TRU-BLOOD") {
                    dAppetite.participantID =  username
                }
                dAppetite.taskRunUUID = String(describing: taskViewController.result.taskRunUUID as UUID)
                dAppetite.timestamp = taskViewController.result.startDate as NSDate? as Date?
                dAppetite.timestampString = formatter.string(from: taskViewController.result.startDate)
                dAppetite.timestampEnd = taskViewController.result.endDate as NSDate? as Date?
                dAppetite.timestampEndString = formatter.string(from: taskViewController.result.endDate)
                dAppetite.dayString = dayFormatter.string(from: date!)
                dAppetite.metric = "pct"
                dAppetite.appetiteTotal = carePlanResult.valueString
                
                var dailyMeals = [String: String]()
                dailyMeals["taskRunUUID"] = String(describing: taskViewController.result.taskRunUUID as UUID)
                dailyMeals["dataEntryStartingTime"] = formatter.string(from: taskViewController.result.startDate)
                dailyMeals["dataEntryEndingTime"] = formatter.string(from: taskViewController.result.endDate)
                dailyMeals["forDayString"] = dayFormatter.string(from: date!)
                dailyMeals["metric"] = "pct"
                dailyMeals["mealsTotal_pct"] = carePlanResult.valueString
                dailyMeals["dataOfType"] = "Meals"
                dailyMeals["dateOfEvent"] = dayFormatter.string(from: date!)
                dailyMeals["dayOfWeekOfEvent"] = dayOfWeekFormatter.string(from: date!)
                dailyMeals["monthOfYearOfEvent"] = monthOfYearDateFormatter.string(from: date!)
                dailyMeals["yearOfEvent"] = yearOfEventDateFormatter.string(from: date!)

                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    print("version of app \(version)")
                    dailyMeals["appVersion"] = version
                }
                if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                    print("version of app \(build)")
                    dailyMeals["appBuild"] = build
                }
                
                for stepResult: ORKStepResult in results {
                    print("##### appetite > \(carePlanResult.valueString) result start date and identifier \n")
                    
                    for result in stepResult.results! {
                        if let questionResult = result as? ORKChoiceQuestionResult {
                            
                            if questionResult.identifier == "breakfast_status" {
                                let response = questionResult.answer as? Array<Any>
                                //print("questionResult.answer to save \(String(describing: response))")
                                dAppetite.breakfast = response?[0] as? String
                                dailyMeals["breakfast"] = response?[0] as? String
                            }
                            
                            if questionResult.identifier == "lunch_status" {
                                let response = questionResult.answer as? Array<Any>
                                //print("questionResult.answer to save \(String(describing: response))")
                                dAppetite.lunch = response?[0] as? String
                                dailyMeals["lunch"] = response?[0] as? String
                            }
                            
                            if questionResult.identifier == "dinner_status" {
                                let response = questionResult.answer as? Array<Any>
                                //print("questionResult.answer to save \(String(describing: response))")
                                dAppetite.dinner = response?[0] as? String
                                dailyMeals["dinner"] = response?[0] as? String
                            }
                        }
                    }
                }
                
                
                let handle = Auth.auth().addStateDidChangeListener { (auth, user) in
                    if let user = user {
                        // The user's ID, unique to the Firebase project.
                        // Do NOT use this value to authenticate with your backend server,
                        // if you have one. Use getTokenWithCompletion:completion: instead.
                        let uid = user.uid
                        let email = user.email
                        //let photoURL = user.photoURL
                        // ...
                        print("user.uid \(uid)")
                        print("user.email \(String(describing: email))")
                        dailyMeals["userID"] = uid
                        dailyMeals["userEmail"] = email
                        dailyMeals["appMode"] = self.appMode(email: email!)
                        dailyMeals["author_id"] = uid
                        
                        let idForFirestore = "DailyMeals." + dayFormatter.string(from: date!) + "." + uid
                        
                        var ref: DocumentReference? = nil
                        self.db.collection("meals").document(idForFirestore).setData(dailyMeals) { err in
                            
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document successfully written!")
                            }
                        }
                    }
                }
                
                
                
                
                //SAVE
                listDataManager.saveCareData()
                //Get an array of the rows in coredata to upload.
                let appetite = listDataManager.findAppetite(entityName: "DAppetite") as [DAppetite]
                if  appetite.count > 0 {
                    var archive:[[String]] = [[]]
                    let headerArray = ["participantID","taskRunUUID","timestampString","timestampEndString","breakfast","lunch","dinner","appetiteTotal","metric","dayString"]
                    //for index "index" and element "e" enumerate the elements of symptoms.
                    for (index, e) in appetite.enumerated() {
                        let ar = [e.participantID, e.taskRunUUID, e.timestampString, e.timestampEndString, e.breakfast, e.lunch, e.dinner, e.appetiteTotal, e.metric, e.dayString  ]
                        archive.append(ar as! [String])
                        print("item: \(e.appetiteTotal ?? "-999")) \(index):\(e)")
 
                        
                    }
                    archive.remove(at: 0)
                    archive.insert(headerArray, at: 0)
                    print(archive)
                    //upload array of arrays as a CSV file
                    let uploadSymptomFocus = UploadApi()
                    uploadSymptomFocus.writeAndUploadCSVToSharefile(forSymptomFocus: archive, "appetite.csv")
                    
                    
                }
                
            }
            //  END Appetite
            
            
            
            
            //START Pain General Health
            if taskViewController.result.identifier == "generalHealth" {
                var dGeneralHealth: DGeneralHealth!
                dGeneralHealth = listDataManager.createGeneralHealth(entityName: "DGeneralHealth") as DGeneralHealth
                
                let keychain = KeychainSwift()
                if let username = keychain.get("username_TRU-BLOOD") {
                    dGeneralHealth.participantID =  username
                }
                dGeneralHealth.taskRunUUID = String(describing: taskViewController.result.taskRunUUID as UUID)
                dGeneralHealth.timestamp = taskViewController.result.startDate as NSDate? as Date?
                dGeneralHealth.timestampString = formatter.string(from: taskViewController.result.startDate)
                dGeneralHealth.timestampEnd = taskViewController.result.endDate as NSDate? as Date?
                dGeneralHealth.timestampEndString = formatter.string(from: taskViewController.result.endDate)
                dGeneralHealth.metric = "outOf10"
                dGeneralHealth.dateString = formatter.string(from: date!)
                dGeneralHealth.dayString = dayFormatter.string(from: date!)
                
                
                var dailyHealth = [String: String]()
                dailyHealth["dataOfType"] = "General Health"
                dailyHealth["taskRunUUID"] = String(describing: taskViewController.result.taskRunUUID as UUID)
                dailyHealth["dataEntryStartingTime"] = formatter.string(from: taskViewController.result.startDate)
                dailyHealth["dataEntryEndingTime"] = formatter.string(from: taskViewController.result.endDate)
                dailyHealth["dateOfEvent"] = dayFormatter.string(from: date!)
                dailyHealth["dayOfWeekOfEvent"] = dayOfWeekFormatter.string(from: date!)
                dailyHealth["monthOfYearOfEvent"] = monthOfYearDateFormatter.string(from: date!)
                dailyHealth["yearOfEvent"] = yearOfEventDateFormatter.string(from: date!)
                
                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    print("version of app \(version)")
                    dailyHealth["appVersion"] = version
                }
                if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                    print("version of app \(build)")
                    dailyHealth["appBuild"] = build
                }
                
                
                
                for stepResult: ORKStepResult in results {
                    print("#####  > result start date and identifier \n")
                    for result in stepResult.results! {
                        if let questionResult = result as? ORKQuestionResult {
                        
                            if questionResult.identifier == "GeneralHealth" {
                                let response = questionResult.answer as! NSNumber
                                print("questionResult.answer to save \(response)")
                                dGeneralHealth.generalHealth = String(describing: response)
                                print("general health \(String(describing: response))")
                                dailyHealth["generalHealth"] = String(describing: response)
                            }
                            
                            if questionResult.identifier == "GeneralHealthComparison" {
                                let response = questionResult.answer as! NSNumber
                                print("questionResult.answer to save \(response)")
                                dGeneralHealth.generalHealthComparison = String(describing: response)
                                print("general health comparison \(String(describing: response))")
                                dailyHealth["healthComparedToYesterday"] = String(describing: response)
                            }
                            
                            if questionResult.identifier == "ActivityLimitationItem" {
                                let response = questionResult.answer as! NSNumber
                                print("questionResult.answer to save \(response)")
                                dGeneralHealth.activityLimitation = String(describing: response)
                                print("activity limitation \(String(describing: response))")
                                dailyHealth["activityLimitationItem"] = String(describing: response)
                            }
                            
                            if questionResult.identifier == "StressItem" {
                                let response = questionResult.answer as! NSNumber
                                print("questionResult.answer to save \(response)")
                                dGeneralHealth.stress = String(describing: response)
                                print("Stress \(String(describing: response))")
                                dailyHealth["stressItem"] = String(describing: response)
                            }
                            
                            if questionResult.identifier == "SleepQualityItem" {
                                let response = questionResult.answer as! NSNumber
                                print("questionResult.answer to save \(response)")
                                dGeneralHealth.sleepQuality = String(describing: response)
                                print("sleep quality \(String(describing: response))")
                                dailyHealth["sleepQualityItem"] = String(describing: response)
                            }
                            
                            if questionResult.identifier == "SleepHoursItem" {
                                let response = questionResult.answer as! NSNumber
                                print("questionResult.answer to save \(response)")
                                dGeneralHealth.sleepHours = String(describing: response)
                                print("Sleep hours \(String(describing: response))")
                                dailyHealth["sleepHoursItem"] = String(describing: response)
                            }
                           
                            
                            
                        }
                    }
                }
                
                let handle = Auth.auth().addStateDidChangeListener { (auth, user) in
                    if let user = user {
                        
                        let uid = user.uid
                        let email = user.email
                        //let photoURL = user.photoURL
                       
                        dailyHealth["userID"] = uid
                        dailyHealth["userEmail"] = email
                        dailyHealth["appMode"] = self.appMode(email: email!)
                        dailyHealth["author_id"] = uid
                        
                        let idForFirestore = "DailyHealth." + dayFormatter.string(from: date!) + "." + uid
                        
                        var ref: DocumentReference? = nil
                        self.db.collection("healths").document(idForFirestore).setData(dailyHealth) { err in
                            
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document successfully written!")
                            }
                        }
                    }
                }
                
                //SAVE
                listDataManager.saveCareData()
                
                
                
                //Get an array of the rows in coredata to upload.
                let generalHealth = listDataManager.findGeneralHealth(entityName: "DGeneralHealth") as [DGeneralHealth]
                if generalHealth .count > 0 {
                    var archive:[[String]] = [[]]
                    let headerArray = ["participantID","dateString","taskRunUUID","generalHealth", "generalHealthComparison","stress","sleepHours","sleepQuality","activityLimitation","timestampString","timestampEndString","dayString"]
                    //for index "index" and element "e" enumerate the elements of symptoms.
                    for (index, e) in generalHealth.enumerated() {
                        let ar = [e.participantID, e.dateString, e.taskRunUUID, e.generalHealth, e.generalHealthComparison, e.stress, e.sleepHours, e.sleepQuality, e.activityLimitation, e.timestampString, e.timestampEndString, e.dayString]
                        print("item:  \(index):\(e)")
                        archive.append(ar as! [String])
                        
                    }
                    archive.remove(at: 0)
                    archive.insert(headerArray, at: 0)
                    print(archive)
                    //upload array of arrays as a CSV file
                    let uploadSymptomFocus = UploadApi()
                    uploadSymptomFocus.writeAndUploadCSVToSharefile(forSymptomFocus: archive, "generalHealth.csv")
                    
                }
                
            }
            //  END Pain General Health
            
            
            //  START Stool
            if taskViewController.result.identifier == "stoolConsistency" {
                var dStool: DStool!
                dStool = listDataManager.createDStool(entityName: "DStool") as DStool
                let keychain = KeychainSwift()
                if let username = keychain.get("username_TRU-BLOOD") {
                    dStool.participantID =  username
                }
                dStool.taskRunUUID = String(describing: taskViewController.result.taskRunUUID as UUID)
                dStool.timestamp = taskViewController.result.startDate as NSDate? as Date? as Date?
                dStool.timestampString = formatter.string(from: taskViewController.result.startDate)
                dStool.timestampEnd = taskViewController.result.endDate as NSDate? as Date?
                dStool.timestampEndString = formatter.string(from: taskViewController.result.endDate)
                dStool.dateString = formatter.string(from: date!)
                dStool.dayString = dayFormatter.string(from: date!)
                
                
                var dailyStools = [String: String]()
                dailyStools["dataOfType"] = "Stools"
                dailyStools["taskRunUUID"] = String(describing: taskViewController.result.taskRunUUID as UUID)
                dailyStools["dataEntryStartingTime"] = formatter.string(from: taskViewController.result.startDate)
                dailyStools["dataEntryEndingTime"] = formatter.string(from: taskViewController.result.endDate)
                dailyStools["dateOfEvent"] = dayFormatter.string(from: date!)
                dailyStools["dayOfWeekOfEvent"] = dayOfWeekFormatter.string(from: date!)
                dailyStools["monthOfYearOfEvent"] = monthOfYearDateFormatter.string(from: date!)
                dailyStools["yearOfEvent"] = yearOfEventDateFormatter.string(from: date!)
                
                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    print("version of app \(version)")
                    dailyStools["appVersion"] = version
                }
                if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                    print("version of app \(build)")
                    dailyStools["appBuild"] = build
                }
                
                
                for stepResult: ORKStepResult in results {
                    for result in stepResult.results! {
                        if let questionResult = result as? ORKQuestionResult {
                            
                            //Stool type
                            if questionResult.identifier == "BStoolT1" {
                                if let response = questionResult.answer {
                                    print("stool type 01 questionResult.answer to save \(response)")
                                    dStool.type1 = String(describing: response)
                                    dailyStools["type1"] = String(describing: response)
                                } else {
                                    dStool.type1 = "0"
                                    dailyStools["type1"] = "0"
                                    print("zero")
                                }
                            }
                            if questionResult.identifier == "BStoolT2" {
                                if let response = questionResult.answer {
                                    print("stool type 02 questionResult.answer to save \(response)")
                                    dStool.type2 = String(describing: response)
                                    dailyStools["type2"] = String(describing: response)
                                } else {
                                    dStool.type2 = "0"
                                    dailyStools["type2"] = "0"
                                    print("zero")
                                }
                            }
                            if questionResult.identifier == "BStoolT3" {
                                if let response = questionResult.answer {
                                    print("stool type 03 questionResult.answer to save \(response)")
                                    dStool.type3 = String(describing: response)
                                    dailyStools["type3"] = String(describing: response)
                                } else {
                                    dStool.type3 = "0"
                                    dailyStools["type3"] = "0"
                                    print("zero")
                                }
                            }
                            if questionResult.identifier == "BStoolT4" {
                                if let response = questionResult.answer {
                                    print("stool type 04 questionResult.answer to save \(response)")
                                    dStool.type4 = String(describing: response)
                                    dailyStools["type4"] = String(describing: response)
                                } else {
                                    dStool.type4 = "0"
                                    dailyStools["type4"] = "0"
                                    print("zero")
                                }
                            }
                            if questionResult.identifier == "BStoolT5" {
                                if let response = questionResult.answer {
                                    print("stool type 05 questionResult.answer to save \(response)")
                                    dStool.type5 = String(describing: response)
                                    dailyStools["type5"] = String(describing: response)
                                } else {
                                    dStool.type5 = "0"
                                    dailyStools["type5"] = "0"
                                    print("zero")
                                }
                            }
                            if questionResult.identifier == "BStoolT6" {
                                if let response = questionResult.answer {
                                    print("stool type 06 questionResult.answer to save \(response)")
                                    dStool.type6 = String(describing: response)
                                    dailyStools["type6"] = String(describing: response)
                                } else {
                                    dStool.type6 = "0"
                                    dailyStools["type6"] = "0"
                                    print("zero")
                                }
                            }
                            if questionResult.identifier == "BStoolT7" {
                                if let response = questionResult.answer {
                                    print("stool type 07 questionResult.answer to save \(response)")
                                    dStool.type7 = String(describing: response)
                                    dailyStools["type7"] = String(describing: response)
                                } else {
                                    dStool.type7 = "0"
                                    dailyStools["type7"] = "0"
                                    print("zero")
                                }
                            }
                            
                            
                            /*
                            if questionResult.identifier == "BStoolT1" {
                                var response = 0
                                guard questionResult.answer != nil else {
                                    // Value requirements not met, keep response to 0 as assigned
                                    dStool.type1 = String(describing: response)
                                    return
                                }
                                
                                response = Int(questionResult.answer as! NSNumber)
                                print("questionResult.answer to save \(response)")
                                dStool.type1 = String(describing: response)
                            }
                            
                            if questionResult.identifier == "BStoolT2" {
                                var response = 0
                                guard questionResult.answer != nil else {
                                    dStool.type2 = String(describing: response)
                                    return
                                }
                                response = Int(questionResult.answer as! NSNumber)
                                print("questionResult.answer to save \(response)")
                                dStool.type2 = String(describing: response)
                            }
                            
                            if questionResult.identifier == "BStoolT3" {
                                var response = 0
                                guard questionResult.answer != nil else {
                                    dStool.type3 = String(describing: response)
                                    return
                                }
                                
                                response = Int(questionResult.answer as! NSNumber)
                                print("questionResult.answer to save \(response)")
                                dStool.type3 = String(describing: response)
                            }
                            
                            if questionResult.identifier == "BStoolT4" {
                                var response = 0
                                guard questionResult.answer != nil else {
                                    dStool.type4 = String(describing: response)
                                    return
                                }
                                
                                response = Int(questionResult.answer as! NSNumber)
                                print("questionResult.answer to save \(response)")
                                dStool.type4 = String(describing: response)
                            }
                            
                            if questionResult.identifier == "BStoolT5" {
                                let response = 0
                                guard questionResult.answer != nil else {
                                    dStool.type5 = String(describing: response)
                                    return
                                }
                                
                                dStool.type5 = String(describing: Int(questionResult.answer as! NSNumber))
                            }
                            
                            if questionResult.identifier == "BStoolT6" {
                                let response = 0
                                guard questionResult.answer != nil else {
                                    dStool.type6 = String(describing: response)
                                    return
                                }
                                
                                dStool.type6 = String(describing: Int(questionResult.answer as! NSNumber))
                            }
                            
                            if questionResult.identifier == "BStoolT7" {
                                let response = 0
                                guard questionResult.answer != nil else {
                                    dStool.type7 = String(describing: response)
                                    return
                                }
                                dStool.type7 = String(describing: Int(questionResult.answer as! NSNumber))
                            }*/
                        }
                    }
                }
                
                let handle = Auth.auth().addStateDidChangeListener { (auth, user) in
                    if let user = user {
                        
                        let uid = user.uid
                        let email = user.email
                        //let photoURL = user.photoURL
                        
                        dailyStools["userID"] = uid
                        dailyStools["userEmail"] = email
                        dailyStools["appMode"] = self.appMode(email: email!)
                        dailyStools["author_id"] = uid
                        
                        let idForFirestore = "DailyStools." + dayFormatter.string(from: date!) + "." + uid
                        
                        var ref: DocumentReference? = nil
                        self.db.collection("stools").document(idForFirestore).setData(dailyStools) { err in
                            
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document successfully written!")
                            }
                        }
                    }
                }
                
                
                //NSManagedObjectContext.default().saveToPersistentStoreAndWait()
                listDataManager.saveCareData()
                
                //Get an array of the rows in coredata to upload.
                let stools = listDataManager.findDStool(entityName: "DStool")  as [DStool]
                if stools .count > 0 {
                    var archive:[[String]] = [[]]
                    let headerArray = ["participantID","dateString","taskRunUUID","Type1","Type2","Type3","Type4","Type5","Type6","Type7","timestampString","timestampEndString","dayString"]
                    //for index "index" and element "e" enumerate the elements of symptoms.
                    for (index, e) in stools.enumerated() {
                        let ar = [e.participantID, e.dateString!, e.taskRunUUID, e.type1, e.type2, e.type3, e.type4, e.type5, e.type6, e.type7, e.timestampString, e.timestampEndString, e.dayString]
                        archive.append(ar as! [String])
                        print("item: \(String(describing:e.dateString)) \(index):\(e)")
                    }
                    archive.remove(at: 0)
                    archive.insert(headerArray, at: 0)
                    print(archive)
                    //upload array of arrays as a CSV file
                    let uploadSymptomFocus = UploadApi()
                    uploadSymptomFocus.writeAndUploadCSVToSharefile(forSymptomFocus: archive, "stool.csv")
                    
                }
            }
            //  ENd Stool
            
            //  START Temperature
            if taskViewController.result.identifier == "temperature" {
                var dTemperature: DTemperature!
                dTemperature = listDataManager.createDTemperature(entityName: "DTemperature") as DTemperature
                
                let keychain = KeychainSwift()
                if let username = keychain.get("username_TRU-BLOOD") {
                    dTemperature.participantID =  username
                }
                dTemperature.taskRunUUID = String(describing: taskViewController.result.taskRunUUID as UUID)
                dTemperature.timestamp = taskViewController.result.startDate as NSDate? as Date?
                dTemperature.timestampString = formatter.string(from: taskViewController.result.startDate)
                dTemperature.timestampEnd = taskViewController.result.endDate as NSDate? as Date?
                dTemperature.timestampEndString = formatter.string(from: taskViewController.result.endDate)
                dTemperature.metric = "degF"
                dTemperature.method = "oral"
                dTemperature.name = "body temperature"
                dTemperature.dayString = dayFormatter.string(from: date!)
                
                for stepResult: ORKStepResult in results {
                    print("#####  > result start date and identifier \n")
                    for result in stepResult.results! {
                        if let questionResult = result as? ORKQuestionResult {
                            if questionResult.identifier == "temperature" {
                                let response = questionResult.answer as! NSNumber
                                print("questionResult.answer to save \(response)")
                                dTemperature.intensity = String(describing: response)
                            }
                            if questionResult.identifier == "temperature_eventTimeStamp" {
                                let date = questionResult.answer! as? NSDate
                                print("date. \(String(describing: date)) 0")
                                dTemperature.date = date as Date?
                                dTemperature.dateString = formatter.string(from: date! as Date)
                                //print("dateString. \(String(describing: dTemperature.dateString)) 0") //this the date the user reports as the event date and time.
                            }
                        }
                    }
                }
                
                //SAVE
                listDataManager.saveCareData()
                
                
                //Get an array of the rows in coredata to upload.
                let temperatures = listDataManager.findDTemperature(entityName: "DTemperature") as [DTemperature]
                if temperatures .count > 0 {
                    var archive:[[String]] = [[]]
                    let headerArray = ["participantID","dateString","taskRunUUID","assesmentName","value","metric","method","timestampString","timestampEndString","dayString"]
                    //for index "index" and element "e" enumerate the elements of symptoms.
                    for (index, e) in temperatures.enumerated() {
                        let ar = [e.participantID, e.dateString, e.taskRunUUID, e.name, e.intensity, e.metric, e.method, e.timestampString, e.timestampEndString, e.dayString]
                        archive.append(ar as! [String])
                        print("item: \(e.name ?? "-999") \(index):\(e)")
                    }
                    archive.remove(at: 0)
                    archive.insert(headerArray, at: 0)
                    print(archive)
                    //upload array of arrays as a CSV file
                    let uploadSymptomFocus = UploadApi()
                    uploadSymptomFocus.writeAndUploadCSVToSharefile(forSymptomFocus: archive, "temperature.csv")
                    
                }
            }
            //  END Temperature
            
            
            
            //START SCDPain
            if taskViewController.result.identifier == "scdPain" {
                var dscdPain: DscdPain!
                dscdPain = listDataManager.createDscdPain(entityName: "DscdPain") as DscdPain
                let keychain = KeychainSwift()
                if let username = keychain.get("username_TRU-BLOOD") {
                    dscdPain.participantID =  username
                }
                dscdPain.taskRunUUID = String(describing: taskViewController.result.taskRunUUID as UUID)
                dscdPain.timestamp = taskViewController.result.startDate as NSDate? as Date?
                dscdPain.timestampString = formatter.string(from: taskViewController.result.startDate)
                dscdPain.timestampEnd = taskViewController.result.endDate as NSDate? as Date?
                dscdPain.timestampEndString = formatter.string(from: taskViewController.result.endDate)
                dscdPain.metric = "outOf10"
                dscdPain.dateString = formatter.string(from: date!)
                dscdPain.dayString = dayFormatter.string(from: date!)
                
                for stepResult: ORKStepResult in results {
                    print("#####  > result start date and identifier \n")
                    for result in stepResult.results! {
                        if let questionResult = result as? ORKQuestionResult {
                            print("#####  > and identifier \n \(questionResult.identifier)")
                            if questionResult.identifier == "scdPain" {
                                let response = questionResult.answer as! Double
                                print("questionResult.answer to save \(response)")
                                dscdPain.scdPain = String(describing: response)
                            }
                            if questionResult.identifier == "scdPain_eventTimeStamp" {
                                print("date scdPain_eventTimeStamp")
                                //let date = questionResult.answer! as? NSDate
                                
                                
                                if let date = questionResult.answer! as? NSDate {
                                    
                                    //this is the today date but not necessarily the date for which this person is entering the data
                                    //we will will replace that date with the date the person is entering the data but keep the time that the perrson want to tenter the data for
                                    print("date. \(date) 0")
                                    dscdPain.date = date as Date
                                    var aString:String = ""
                                    aString = formatter.string(from: date as Date)
                                    let mystring = aString.dropFirst(10)
                                    let realDateTimeString = newDateString+mystring
                                
                                    //print("date. \(date) 0")
                                    
                                    dscdPain.dateString = realDateTimeString
                                    //print("dateString. \(dscdPain.dateString) 0") //this the date the user reports as the event date and time.
                                    print("dateString for SCDPain. \(String(describing: dscdPain.dateString)) 0") //this the date the user reports as the event date and time.
                                } else {
                                    print("we did not enter a date so we could use the current date : \(Date())")
                                }
                                
                            }
                            
                            if questionResult.identifier == "scdPain_status" {
                                if let array = questionResult.answer as? NSArray {
                                    dscdPain.scdPainStatus = array.firstObject as? String
                                }
                            }
                            
                            if questionResult.identifier == "scdPain_affected_body_locations" {
                                let array = questionResult.answer as! NSArray
                                let string = array.componentsJoined(by: ",") as String
                                print("questionResult.answer array to save \(array)")
                                print("questionResult.answer.body  to save as string --> \(string)")
                                dscdPain.bodyLocations = string
                                
                            }
                            
                            if questionResult.identifier == "nonscdPain" {
                                if let array = questionResult.answer as? NSArray {
                                   // print("non scd result\(array.firstObject)")
                                    dscdPain.nonscdPain = String(describing:array.firstObject!)
                                }
                            }
                        }
                    }
                }
                
                listDataManager.saveCareData()
                
                //Get an array of the rows in coredata to upload.
                let scdPain = listDataManager.findDscdPain(entityName: "DscdPain") as [DscdPain]
                if scdPain.count > 0 {
                    var archive:[[String]] = [[]]
                    //TODO set a choice of header array
                    let defaults = Defaults.shared
                    let key = Key<String>("PainTYpe")
                    var headerArray = [String]()
                    if defaults.has(key) {
                        // Do your thing
                        if defaults.get(for: key) == "SurgicalPain" {
                            headerArray = ["participantID","dateString","taskRunUUID","surgicalPain","metric","painStatus","bodyLocations","nonSurgicalPain","timestampString","timestampEndString", "dayString"]
                        } else {
                            headerArray = ["participantID","dateString","taskRunUUID","scdPain","metric","scdPainStatus","bodyLocations","nonSCDpain","timestampString","timestampEndString", "dayString"]
                        }
                    } else {
                        headerArray = ["participantID","dateString","taskRunUUID","scdPain","metric","scdPainStatus","bodyLocations","nonSCDpain","timestampString","timestampEndString", "dayString"]
                    }
                    
                    //for index "index" and element "e" enumerate the elements of symptoms.
                    for (index, e) in scdPain.enumerated() {
                        //print("item: \(e.scdPain)) \(index):\(e)")
                        let ar = [e.participantID, e.dateString, e.taskRunUUID, e.scdPain, e.metric, e.scdPainStatus, e.bodyLocations, e.nonscdPain, e.timestampString, e.timestampEndString, e.dayString ]
                        archive.append(ar as! [String])
                        //                        print("item: \(e.scdPain)) \(index):\(e)")
                    }
                    archive.remove(at: 0)
                    archive.insert(headerArray, at: 0)
                    print(archive)
                    //upload array of arrays as a CSV file
                    let uploadSymptomFocus = UploadApi()
                    uploadSymptomFocus.writeAndUploadCSVToSharefile(forSymptomFocus: archive, "scdPain.csv")
                    
                }
                
            }
            //  END SCDPain
            
            
            
            
            //START DMenstruation
            
            if taskViewController.result.identifier == "menstruation" || taskViewController.result.identifier == "menstruationSCD" {
                var dMenstruation: DMenstruation!
                dMenstruation = listDataManager.createDMenstruation(entityName: "DMenstruation") as DMenstruation
                let keychain = KeychainSwift()
                if let username = keychain.get("username_TRU-BLOOD") {
                    dMenstruation.participantID =  username
                }
                dMenstruation.taskRunUUID = String(describing: taskViewController.result.taskRunUUID as UUID)
                dMenstruation.timestamp = taskViewController.result.startDate as NSDate? as Date?
                dMenstruation.timestampString = formatter.string(from: taskViewController.result.startDate)
                dMenstruation.timestampEnd = taskViewController.result.endDate as NSDate? as Date?
                dMenstruation.timestampEndString = formatter.string(from: taskViewController.result.endDate)
                dMenstruation.dayString = dayFormatter.string(from: date!)
                
                for stepResult: ORKStepResult in results {
                    print("#####  > result start date and identifier \n")
                    for result in stepResult.results! {
                        if let questionResult = result as? ORKQuestionResult {
                            print("#####  > and identifier \n \(questionResult.identifier)")
                            
                            if questionResult.identifier == "symptom_eventTimeStamp" {
                                print("date urineCollectionActualTime")
                                
                                let date = questionResult.answer! as? NSDate
                                //print("date. \(date) 0")
                                dMenstruation.date = date as Date?
                                dMenstruation.dateString = formatter.string(from: date! as Date)
                                //print("dateString. \(dMenstruation.dateString) 0") //this the date the user reports as the event date and time.
                            }
                            
                            if questionResult.identifier == "firstMorningUrine" {
                                if let array = questionResult.answer as? NSArray {
                                    dMenstruation.firstMorningUrine = array.firstObject as? String
                                }
                                
                            }
                            
                            if questionResult.identifier == "spotting" {
                                if let array = questionResult.answer as? NSArray {
                                    dMenstruation.spotting = array.firstObject as? String
                                }
                            }
                            if questionResult.identifier == "menstruating" {
                                if let array = questionResult.answer as? NSArray {
                                    //print("non scd result\(array.firstObject)")
                                    dMenstruation.menstruating = String(describing:array.firstObject!)
                                }
                            }
                            
                            if questionResult.identifier == "lowerAbdominalCramp" {
                                let response = questionResult.answer as! Double
                                print("questionResult.answer to save \(response)")
                                dMenstruation.lowerAbdominalCramp = String(describing: response)
                            }
                            
                            
                            if questionResult.identifier == "differentiatesPain" {
                                if let array = questionResult.answer as? NSArray {
                                    //print("non scd result\(array.firstObject)")
                                    dMenstruation.differentiatesPain = String(describing:array.firstObject!)
                                }
                            }
                            
                            if questionResult.identifier == "differentiatesSCDPainCharacter" {
                                if let array = questionResult.answer as? NSArray {
                                    //print("non scd result\(array.firstObject)")
                                    dMenstruation.differentiatesSCDPainCharacter = String(describing:array.firstObject!)
                                }
                            }
                            
                            
                            //PADS
                            if questionResult.identifier == "pad01" {
                                if let response = questionResult.answer {
                                    print("pad01 questionResult.answer to save \(response)")
                                    dMenstruation.pad01 = String(describing: response)
                                } else {
                                    dMenstruation.pad01 = "0"
                                    print("zero")
                                }
                            }
                            
                            if questionResult.identifier == "pad02" {
                                if let response = questionResult.answer {
                                    print("pad02 questionResult.answer to save \(response)")
                                    dMenstruation.pad02 = String(describing: response)
                                } else {
                                    dMenstruation.pad02 = "0"
                                    print("zero")
                                }
                            }
                            
                            if questionResult.identifier == "pad03" {
                                if let response = questionResult.answer {
                                    print("pad01 questionResult.answer to save \(response)")
                                    dMenstruation.pad03 = String(describing: response)
                                } else {
                                    dMenstruation.pad03 = "0"
                                    print("zero")
                                }
                            }
                            //TAMPONS
                            if questionResult.identifier == "tampon01" {
                                if let response = questionResult.answer {
                                    print("tampon01 questionResult.answer to save \(response)")
                                    dMenstruation.tampon01 = String(describing: response)
                                } else {
                                    dMenstruation.tampon01 = "0"
                                    print("zero")
                                }
                            }
                            
                            if questionResult.identifier == "tampon02" {
                                if let response = questionResult.answer {
                                    print("tampon02 questionResult.answer to save \(response)")
                                    dMenstruation.tampon02 = String(describing: response)
                                } else {
                                    dMenstruation.tampon02 = "0"
                                    print("zero")
                                }
                            }
                            
                            if questionResult.identifier == "tampon03" {
                                if let response = questionResult.answer {
                                    print("tampon03 questionResult.answer to save \(response)")
                                    dMenstruation.tampon03 = String(describing: response)
                                } else {
                                    dMenstruation.tampon03 = "0"
                                    print("zero")
                                }
                            }
                            
                            
                            
                        }
                    }
                }
                
                //SAVE
                listDataManager.saveCareData()
                
                //Get an array of the rows in coredata to upload.
                let menstruation = listDataManager.findDMenstruation(entityName: "DMenstruation") as [DMenstruation]
                if menstruation.count > 0 {
                    var archive:[[String]] = [[]]
                    let headerArray = ["participantID","dateString","taskRunUUID", "firstMorningUrine","spotting","menstruating","lowerAbdominalCramp","differentiatesPain","differentiatesSCDPainCharacter",
                                       "padSmallSoil","padMediumSoil","padLargeSoil","tamponSmallSoil", "tamponMediumSoil", "tamponLargeSoil","timestampString","timestampEndString","dayString"]
                    //for index "index" and element "e" enumerate the elements of symptoms.
                    for (index, e) in menstruation.enumerated() {
                        //print("item: \(e.menstruating)) \(index):\(e)")
//                        var differentiatesSCDPainCharacter: String?
//                        guard e.differentiatesSCDPainCharacter != nil else {
//                            differentiatesSCDPainCharacter = "-99"
//                            return
//                        }
                        
                        
                        let missingValue = "-99"
                        
                        let ar = [e.participantID, e.dateString, e.taskRunUUID, e.firstMorningUrine, e.spotting, e.menstruating, e.lowerAbdominalCramp, e.differentiatesPain, e.differentiatesSCDPainCharacter ?? missingValue,
                                  e.pad01,e.pad02, e.pad03, e.tampon01, e.tampon02, e.tampon03, e.timestampString, e.timestampEndString, e.dayString ]
                        archive.append(ar as! [String])
                        //                        print("item: \(e.scdPain)) \(index):\(e)")
                    }
                    archive.remove(at: 0)
                    archive.insert(headerArray, at: 0)
                    print(archive)
                    //upload array of arrays as a CSV file
                    let uploadSymptomFocus = UploadApi()
                    uploadSymptomFocus.writeAndUploadCSVToSharefile(forSymptomFocus: archive, "menstruation.csv")
                    
                }
            }
            //  END DMenstruation
            
        }
        
        
        
        // Determine the event that was completed and the `SampleAssessment` it represents.
        //        guard let event = symptomTrackerViewController.lastSelectedAssessmentEvent,
        //            let activityType = ActivityType(rawValue: event.activity.identifier),
        //            let sampleAssessment = sampleData.activityWithType(activityType) as? Assessment else { return }
        
        // Build an `OCKCarePlanEventResult` that can be saved into the `OCKCarePlanStore`.
        let carePlanResult = sampleAssessment.buildResultForCarePlanEvent(event, taskResult: taskViewController.result)
        
        //        let dataManager = DataManager(baseURL: API.AuthenticatedBaseURL)
        //        dataManager.dataFromTasksRVC(taskUUID: String(describing: taskViewController.result.taskRunUUID as UUID),
        //                                     timestamp: carePlanResult.creationDate, timestampString: formatter.string(from: taskViewController.result.startDate))
        
        print("carePlanResult.creationDate")
        print(carePlanResult.creationDate)
        print(event.date) //this is in date components
        print(event.debugDescription)
        print(event.activity.title)
        print(sampleAssessment.activityType)
        //        print(carePlanResult.valueString)
        
        
        //private var _dGeoData:DGeoData?
        let dGeoData = listDataManager.createGeoData(entityName: "DGeoData") as DGeoData
        let keychain = KeychainSwift()
        if let username = keychain.get("username_TRU-BLOOD") {
            dGeoData.participantID =  username
        }
        
        dGeoData.taskUUID = String(describing: taskViewController.result.taskRunUUID as UUID)
        dGeoData.timestamp = carePlanResult.creationDate as NSDate? as Date?
        dGeoData.timestampString = formatter.string(from: taskViewController.result.startDate)
        listDataManager.saveCareData()
        
        
        self.taskUUID = taskViewController.result.taskRunUUID as UUID
        //print("TASK ID \(self.taskUUID)")
        
        
        self.findCurrentLocation(taskID: String(describing:self.taskUUID))
        
        
        
        // Check assessment can be associated with a HealthKit sample.
        if let healthSampleBuilder = sampleAssessment as? HealthSampleBuilder {
            // Build the sample to save in the HealthKit store.
            print("Build the sample to save in the HealthKit store.")
            let sample = healthSampleBuilder.buildSampleWithTaskResult(taskViewController.result)
            let sampleTypes: Set<HKSampleType> = [sample.sampleType]
            
            // Requst authorization to store the HealthKit sample.
            let healthStore = HKHealthStore()
            healthStore.requestAuthorization(toShare: sampleTypes, read: sampleTypes, completion: { success, _ in
                // Check if authorization was granted.
                if !success {
                    /*
                     Fall back to saving the simple `OCKCarePlanEventResult`
                     in the `OCKCarePlanStore`.
                     */
                    self.completeEvent(event, inStore: self.storeManager.store, withResult: carePlanResult)
                    return
                }
                
                // Save the HealthKit sample in the HealthKit store.
                healthStore.save(sample, withCompletion: { success, _ in
                    if success {
                        /*
                         The sample was saved to the HealthKit store. Use it
                         to create an `OCKCarePlanEventResult` and save that
                         to the `OCKCarePlanStore`.
                         */
                        print("The sample was saved to the HealthKit store.")
                        let healthKitAssociatedResult = OCKCarePlanEventResult(
                            quantitySample: sample,
                            quantityStringFormatter: nil,
                            display: healthSampleBuilder.unit,
                            displayUnitStringKey: healthSampleBuilder.localizedUnitForSample(sample),
                            userInfo: nil
                        )
                        
                        self.completeEvent(event, inStore: self.storeManager.store, withResult: healthKitAssociatedResult)
                    }
                    else {
                        /*
                         Fall back to saving the simple `OCKCarePlanEventResult`
                         in the `OCKCarePlanStore`.
                         */
                        self.completeEvent(event, inStore: self.storeManager.store, withResult: carePlanResult)
                    }
                    
                })
            })
        }
        else {
            // Update the event with the result.
            completeEvent(event, inStore: storeManager.store, withResult: carePlanResult)
        }
        
    }
    
    // MARK: Convenience
    
    fileprivate func completeEvent(_ event: OCKCarePlanEvent, inStore store: OCKCarePlanStore, withResult result: OCKCarePlanEventResult) {
        store.update(event, with: result, state: .completed) { success, _, error in
            if !success {
                print(error?.localizedDescription as Any)
            }
        }
    }
}

// MARK: OCKConnectViewControllerDelegate
// MARK: CarePlanStoreManagerDelegate
extension RootViewController: CarePlanStoreManagerDelegate {
    /// Called when the `CarePlanStoreManager`'s insights are updated.
    func carePlanStoreManager(_ manager: CarePlanStoreManager, didUpdateInsights insights: [OCKInsightItem]) {
        // Update the insights view controller with the new insights.
        insightsViewController.items = insights
        
    }
    
}
extension RootViewController: OCKConnectViewControllerDelegate {
    
    /// Called when the user taps a contact in the `OCKConnectViewController`.
    func connectViewController(_ connectViewController: OCKConnectViewController, didSelectShareButtonFor contact: OCKContact, presentationSourceView sourceView: UIView?) {
        print("i am called here too")
        
        
        
        if let document = storeManager.generateDocument(comment: "Comments:") {
        
        document.createPDFData { (PDFData, errorOrNil) in
            if let error = errorOrNil {
                print("perform proper error checking here...")
                
                let alertController = UIAlertController(title: "Error!", message: "Document cold not be created", preferredStyle: .alert)
                
                
                let confirmAction = UIAlertAction(title: "Ok", style: .default) { (_) in}
                
                alertController.addAction(confirmAction)
                self.navigationController?.present(alertController, animated: true, completion: nil)
                fatalError(error.localizedDescription)
            }
            
            // Do something with the PDF data here...
            let documentViewController = DocumentsDisplayViewController()
            
            print("\(document.htmlContent)")
            
            documentViewController.documentObject = document
            
            let vc = UIStoryboard(name: "Main", bundle: nil)
            let viewController = vc.instantiateViewController(withIdentifier: "DataReportViewControllerSB")
            
            let modalStyle: UIModalTransitionStyle = UIModalTransitionStyle.coverVertical
            viewController.modalTransitionStyle = modalStyle
            viewController.title = NSLocalizedString("Media", comment: "")
           // self.present(viewController, animated: true, completion: nil)
            
            print("i am presented too")
//            let activityViewController = UIActivityViewController(activityItems: [PDFData], applicationActivities: nil)
//            activityViewController.popoverPresentationController?.sourceView = activityViewController.view
//            activityViewController.popoverPresentationController?.sourceRect = activityViewController.view.bounds
//            self.present(activityViewController, animated: true, completion: nil)
        }
            
        }
    }
}

/*
// MARK: - OCKConnectViewControllerDelegate

extension RootViewController: OCKConnectViewControllerDelegate {
    
    /// Called when the user taps a contact in the `OCKConnectViewController`.
    func connectViewController(_ connectViewController: OCKConnectViewController,
                               didSelectShareButtonFor contact: OCKContact,
                               presentationSourceView sourceView: UIView?) {
        let document = sampleData.generateDocumentWith(chart: insightChart)
        let activityViewController = UIActivityViewController(activityItems: [document.htmlContent],
                                                              applicationActivities: nil)
        
        present(activityViewController, animated: true, completion: nil)
    }
}
*/




// MARK: - CLLocationManagerDelegate
extension RootViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("func locationManager")
        guard let mostRecentLocation = locations.last else {
            print("CL locations returned")
            return
        }
        
        if (self.isFirstUpdate) {
            self.isFirstUpdate = false
            return
        }
        
        print("CL locations")
        
        let location:CLLocation = locations.last!
        if (location.horizontalAccuracy > 0) {
            
//            let keychain = KeychainSwift()
//            if keychain.get("username_TRU-BLOOD") != nil {
//                self.userEmail = keychain.get("username_TRU-BLOOD")!
//            }
            
            
            let dataManager = DataManager(baseURL: API.AuthenticatedBaseURL)
            dataManager.weatherDataForLocation(taskUUID:self.taskUUID!, altitude: mostRecentLocation.altitude,latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { (response, error) in
                print(response ?? "-999")
            }
            //self.currentLocation = location
            print("find my current location: \(location)")
            locationManager.stopUpdatingLocation()
            
            if UIApplication.shared.applicationState == .active {
                //                mapView.showAnnotations(self.locations, animated: true)
                print("App is foregrounded. New location is %@", mostRecentLocation.timestamp)
                print("App is foregrounded. New location is %@", mostRecentLocation.altitude)
                print("App is foregrounded. New location is %@", mostRecentLocation.course)
                print("App is foregrounded. New location is %@", mostRecentLocation.speed)
                print("App is foregrounded. New location is %@", mostRecentLocation.verticalAccuracy)
                print("App is foregrounded. New location is %@", mostRecentLocation.distance(from: location))
                
            } else {
                print("App is backgrounded. New location is %@", mostRecentLocation)
            }
        }
        
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
