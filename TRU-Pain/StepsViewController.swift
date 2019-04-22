//
//  StepsViewController.swift
//  TRU-BMT
//
//  Created by Jude on 4/13/19.
//  Copyright © 2019 scdi. All rights reserved.
//


import UIKit
import HealthKit

class StepsViewController: UIViewController {
    let debugLabel = UILabel(frame: CGRect(x: 10,y: 20,width: 350,height: 600))
    var heartRateQuery:HKObserverQuery?
    public let healthStore = HKHealthStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = UIView();
        self.view.backgroundColor = UIColor.white
        
        
        debugLabel.textAlignment = NSTextAlignment.center
        debugLabel.textColor = UIColor.black
        debugLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        debugLabel.numberOfLines = 0
        self.view.addSubview(debugLabel)
        debugLabel.text = "OK we are here."
        
        self.getDailySteps()
        self.subscribeToHeartBeatChanges()
        //        self.getWeeklySteps()
    }
    ///TEST FUNCTIONS
    public func subscribeToHeartBeatChanges() {
        
        // Creating the sample for the heart rate
        guard let sampleType: HKSampleType =
            HKObjectType.quantityType(forIdentifier: .heartRate) else {
                return
        }
        
        /// Creating an observer, so updates are received whenever HealthKit’s
        // heart rate data changes.
        self.heartRateQuery = HKObserverQuery.init(
            sampleType: sampleType,
            predicate: nil) { [weak self] _, _, error in
                guard error == nil else {
                    //log.warn(error!)
                    return
                }
                
                /// When the completion is called, an other query is executed
                /// to fetch the latest heart rate
                self?.fetchLatestHeartRateSample(completion: { sample in
                    guard let sample = sample else {
                        return
                    }
                    
                    /// The completion in called on a background thread, but we
                    /// need to update the UI on the main.
                    DispatchQueue.main.async {
                        
                        /// Converting the heart rate to bpm
                        let heartRateUnit = HKUnit(from: "count/min")
                        let heartRate = sample
                            .quantity
                            .doubleValue(for: heartRateUnit)
                        
                        /// Updating the UI with the retrieved value
                        //self?.heartRateLabel.setText("\(Int(heartRate))")
                        print("heart rate value \(Int(heartRate))")
                    }
                })
        }
    }
    
    public func fetchLatestHeartRateSample(
        completion: @escaping (_ sample: HKQuantitySample?) -> Void) {
        
        /// Create sample type for the heart rate
        guard let sampleType = HKObjectType
            .quantityType(forIdentifier: .heartRate) else {
                completion(nil)
                return
        }
        
        /// Predicate for specifiying start and end dates for the query
        let predicate = HKQuery
            .predicateForSamples(
                withStart: Date.distantPast,
                end: Date(),
                options: .strictEndDate)
        
        /// Set sorting by date.
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false)
        
        /// Create the query
        let query = HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: Int(HKObjectQueryNoLimit),
            sortDescriptors: [sortDescriptor]) { (_, results, error) in
                
                guard error == nil else {
                    print("Error: \(error!.localizedDescription)")
                    return
                }
                
                completion(results?[0] as? HKQuantitySample)
        }
        
        self.healthStore.execute(query)
    }
    func getWeeklySteps() {
        let calendar = NSCalendar.current
        
        let interval = NSDateComponents()
        interval.day = 7
        
        // Set the anchor date to Monday at 3:00 a.m.
        var anchorComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: NSDate() as Date)
        
        
        let offset = (7 + anchorComponents.weekday! - 2) % 7
        anchorComponents.day = anchorComponents.day!-offset
        anchorComponents.hour = 3
        
        //        guard let anchorDate = calendar.dateFromComponents(anchorComponents) else {
        //            fatalError("*** unable to create a valid date from the given components ***")
        //        }
        
        guard let anchorDate = calendar.date(from: anchorComponents) else {
            fatalError("*** unable to create a valid date from the given components ***")
        }
        
        //        guard let quantityType = HKObjectType.quantityType(HKQuantityTypeIdentifier.stepCountforIdentifier: ) else {
        //            fatalError("*** Unable to create a step count type ***")
        //        }
        if HKHealthStore.isHealthDataAvailable() {
            let healthStore = HKHealthStore()
            
            guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else {
                fatalError("*** Unable to create a step count type ***")
            }
            
            
            
            let options:HKStatisticsOptions = [HKStatisticsOptions.cumulativeSum, HKStatisticsOptions.separateBySource]
            // Create the query
            let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                    quantitySamplePredicate: nil,
                                                    options: options,
                                                    anchorDate: anchorDate,
                                                    intervalComponents: interval as DateComponents)
            
            // Set the results handler
            query.initialResultsHandler = {
                query, results, error in
                
                guard let statsCollection = results else {
                    // Perform proper error handling here
                    fatalError("*** An error occurred while calculating the statistics: \(String(describing: error?.localizedDescription)) ***")
                }
                
                let endDate = NSDate()
                
                guard let startDate = calendar.date(byAdding: .month, value: -7, to: endDate as Date) else {
                    fatalError("*** Unable to calculate the start date ***")
                }
                
                // Plot the weekly step counts over the past 3 months
                statsCollection.enumerateStatistics(from: startDate, to: endDate as Date) { [unowned self] statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        let date = statistics.startDate
                        let value = quantity.doubleValue(for: HKUnit.count())
                        
                        // Call a custom method to plot each data point.
                        //self.plotWeeklyStepCount(value, forDate: date)
                        print("Number Steps: \(value) for week starting: \(date)")
                        
                        //                    self.debugLabel.text = String(value) + String(describing:date) // this would need to be running on the main thread.
                    }
                }
            }
            
            healthStore.execute(query)
        }
        
    }
    
    func getDailySteps() {
        let calendar = NSCalendar.current
        
        let interval = NSDateComponents()
        interval.day = 1
        
        // Set the anchor date to Monday at 3:00 a.m.
        var anchorComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: NSDate() as Date)
        
        
        let offset = (1 + anchorComponents.weekday! - 2) % 1
        anchorComponents.day = anchorComponents.day!-offset
        anchorComponents.hour = 3
        
        //        guard let anchorDate = calendar.dateFromComponents(anchorComponents) else {
        //            fatalError("*** unable to create a valid date from the given components ***")
        //        }
        
        guard let anchorDate = calendar.date(from: anchorComponents) else {
            fatalError("*** unable to create a valid date from the given components ***")
        }
        
        //        guard let quantityType = HKObjectType.quantityType(HKQuantityTypeIdentifier.stepCountforIdentifier: ) else {
        //            fatalError("*** Unable to create a step count type ***")
        //        }
        if HKHealthStore.isHealthDataAvailable() {
            let healthStore = HKHealthStore()
            
            guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else {
                fatalError("*** Unable to create a step count type ***")
            }
            
            
            
            let options:HKStatisticsOptions = [HKStatisticsOptions.cumulativeSum, HKStatisticsOptions.separateBySource]
            // Create the query
            let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                    quantitySamplePredicate: nil,
                                                    options: options,
                                                    anchorDate: anchorDate,
                                                    intervalComponents: interval as DateComponents)
            
            // Set the results handler
            query.initialResultsHandler = {
                query, results, error in
                
                guard let statsCollection = results else {
                    // Perform proper error handling here
                    fatalError("*** An error occurred while calculating the statistics: \(String(describing: error?.localizedDescription)) ***")
                }
                
                let endDate = NSDate()
                
                guard let startDate = calendar.date(byAdding: .month, value: -7, to: endDate as Date) else {
                    fatalError("*** Unable to calculate the start date ***")
                }
                
                // Plot the weekly step counts over the past 3 months
                statsCollection.enumerateStatistics(from: startDate, to: endDate as Date) { [unowned self] statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        let date = statistics.startDate
                        let value = quantity.doubleValue(for: HKUnit.count())
                        let source = statistics.sources
                        
                        // Call a custom method to plot each data point.
                        //self.plotWeeklyStepCount(value, forDate: date)
                        print("Number Steps: \(value) for week starting: \(date) SOURCE: \(String(describing: source))")
                        
                        //self.debugLabel.text = String(value) + String(describing:date) // this would need to be running on the main thread.
                    }
                }
                
            }
            
            healthStore.execute(query)
        }
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
