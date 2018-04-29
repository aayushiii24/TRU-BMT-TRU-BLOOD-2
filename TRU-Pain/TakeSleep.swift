//
//  TakeSleep.swift
//  TRU-Care
//
//  Created by scdi on 6/4/16.
//  Copyright © 2016 scdi. All rights reserved.
//

import CareKit

/**
 Struct that conforms to the `Activity` protocol to define an activity to take
 medication.
 */
struct TakeSleep: Activity {
    // MARK: Activity
    
    let activityType: ActivityType = .takeSleep
    
    func carePlanActivity() -> OCKCarePlanActivity {
        // Create a weekly schedule.
        let startDate = NSDateComponents(year: 2017, month: 01, day: 01)
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [4,4,4,4,4,4,4])
        
        // Get the localized strings to use for the activity.
        let title = NSLocalizedString("Rest", comment: "")
        let summary = NSLocalizedString("Each circle represents 10-15 minutes, you rested today", comment: "")
        let instructions = NSLocalizedString("Attempt to get 3 short rest periods each day", comment: "")
        
        let activity = OCKCarePlanActivity.intervention(
            withIdentifier: activityType.rawValue,
            groupIdentifier: nil,
            title: title,
            text: summary,
            tintColor: Colors.blue.color,
            instructions: instructions,
            imageURL: nil,
            schedule: schedule,
            userInfo: nil,
            optional: true
        )
        
        return activity
    }
}
