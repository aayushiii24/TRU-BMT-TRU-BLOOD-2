//
//  Fruits.swift
//  TRU-Pain
//
//  Created by jonas002 on 7/4/17.
//  Copyright © 2017 scdi. All rights reserved.
//

import Foundation
import CareKit

/**
 Struct that conforms to the `Activity` protocol to define getting proper nutrition activity.
 */
struct Fruits: Activity {
    // MARK: Activity
    
    let activityType: ActivityType = .fruits
    
    func carePlanActivity() -> OCKCarePlanActivity {
        // Create a weekly schedule.
        let startDate = DateComponents(year: 2016, month: 01, day: 01)
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [3, 3, 3, 3, 3, 3, 3])
        
        // Get the localized strings to use for the activity.
        let title = NSLocalizedString("Fruits", comment: "")
        let summary = NSLocalizedString("1 circle represents 1 serving", comment: "")
        let instructions = NSLocalizedString("Have adequate portions of each food group daily.", comment: "")
        
        // Create the intervention activity.
        let activity = OCKCarePlanActivity.intervention(
            withIdentifier: activityType.rawValue,
            groupIdentifier: nil,
            title: title,
            text: summary,
            tintColor: Colors.orange.color,
            instructions: instructions,
            imageURL: nil,
            schedule: schedule,
            userInfo: nil,
            optional: false
        )
        return activity
    }
}
