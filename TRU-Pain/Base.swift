///
//  Created by Bryton Shoffner on 3/1/20.
//  Copyright © 2020 Bryton Shoffner. All rights reserved.
//

import HealthKit

public class Base {
    private var healthStore: HKHealthStore
    private var sampleType: HKSampleType
    private var limit: Int
    private var data: [[HKSample]] = []
    
    init(healthStore: HKHealthStore, sampleType: HKSampleType, limit: Int = Int(HKObjectQueryNoLimit)) {
        self.healthStore = healthStore
        self.sampleType = sampleType
        self.limit = limit
    }
    
    // Read data from the HealthKit store.
    // By default, does not sort/filter and has no limit to the number of objects queried.
    // Can set a limit in the initializer.
    func capture() {
        let query = HKSampleQuery.init(sampleType: self.sampleType, predicate: nil, limit: self.limit, sortDescriptors: nil, resultsHandler: { (query, results, error) in
            if results != nil {
                self.data.append(results!)
            } else {
                // Couldn't get results, handle errors
            }
        })
        
        // Runs the query on an anonymous background queue.
        // When complete, it executes the results handler defined in the query on the same background queue.
        self.healthStore.execute(query)
    }
    
    func getType() -> HKSampleType {
        return self.sampleType
    }
    
    func getData() -> [[HKSample]] {
        return self.data
    }

    static func createSampleTypeSet(sampleType: HKSampleType? = nil) -> Set<HKSampleType> {
        var types: Set<HKSampleType> {
            // Measures the number of steps the user has taken.
            let stepType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
            
            // Measures the user's heart rate.
            let heartRateType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
            
            // Measures the user's heart rate variability in terms of the standard deviation of heartbeat intervals.
            let heartRateVariabilityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRateVariabilitySDNN)!
            
            // Measures the user's oxygen saturation.
            let oxygenType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.oxygenSaturation)!
            
            // An analysis of the user's sleep.
            let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
            
            return [stepType, heartRateType, heartRateVariabilityType, oxygenType, sleepType]
        }
        
        return types
    }
}

