//
//  EatSnak.swift
//  TRU-Care
//
//  Created by scdi on 7/2/16.
//  Copyright © 2016 scdi. All rights reserved.
//

import CareKit

/**
 Struct that conforms to the `Activity` protocol to define an activity to take
 medication.
 */
struct EatSnack: Activity {
    // MARK: Activity
    
    let activityType: ActivityType = .eatSnack
    
    func carePlanActivity() -> OCKCarePlanActivity {
        // Create a weekly schedule.
        let startDate = NSDateComponents(year: 2017, month: 01, day: 01)
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [3, 3, 3, 3, 3, 3, 3])
        
        // Get the localized strings to use for the activity.
        let title = NSLocalizedString("Snacks", comment: "")
        let summary = NSLocalizedString("One circle per snack", comment: "")
        let instructions = NSLocalizedString("Eat snacks or drink shakes as tolerated. If you ate snacks or drank shakes, fill in one circle for each snack or shake you took.", comment: "")
        
        let activity = OCKCarePlanActivity.intervention(
            withIdentifier: activityType.rawValue,
            groupIdentifier: nil,
            title: title,
            text: summary,
            tintColor: Colors.lightBlue.color,
            instructions: instructions,
            imageURL: nil,
            schedule: schedule,
            userInfo: nil,
            optional: false
        )
        return activity
    }
}
