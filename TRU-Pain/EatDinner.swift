//
//  EatDinner.swift
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
struct EatDinner: Activity {
    // MARK: Activity
    
    let activityType: ActivityType = .eatDinner
    
    func carePlanActivity() -> OCKCarePlanActivity {
        // Create a weekly schedule.
        let startDate = NSDateComponents(year: 2017, month: 01, day: 01)
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [3, 3, 3, 3, 3, 3, 3])
        
        // Get the localized strings to use for the activity.
        let title = NSLocalizedString("Meals", comment: "")
        let summary = NSLocalizedString("One circle for each main meal", comment: "")
        let instructions = NSLocalizedString("Eat three meals as tolerated. If you ate some of your meal but not all fill in a circle if the portion you ate is about 50 % or more.", comment: "")
        
        let activity = OCKCarePlanActivity.intervention(
            withIdentifier: activityType.rawValue,
            groupIdentifier: nil,
            title: title,
            text: summary,
            tintColor: Colors.green.color,
            instructions: instructions,
            imageURL: nil,
            schedule: schedule,
            userInfo: nil,
            optional: false
        )
        
        return activity
    }
}
