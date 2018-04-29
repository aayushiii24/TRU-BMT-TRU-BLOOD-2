//
//  GeneralHealth.swift
//  TRU-Care
//
//  Created by jonas002 on 6/25/17.
//  Copyright © 2017 scdi. All rights reserved.
//

import CareKit
import ResearchKit

/**
 Struct that conforms to the `Assessment` protocol to define a back pain
 assessment.
 */
struct GeneralHealth: Assessment {
    // MARK: Activity
    
    let activityType: ActivityType = .generalHealth
    
    func carePlanActivity() -> OCKCarePlanActivity {
        // Create a weekly schedule.
        let startDate = DateComponents(year: 2016, month: 01, day: 01)
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [1, 1, 1, 1, 1, 1, 1])
        
        // Get the localized strings to use for the assessment.
        let title = NSLocalizedString("General Health" , comment: "")
        let summary = NSLocalizedString("Today", comment: "")
        
        let activity = OCKCarePlanActivity.assessment(withIdentifier: activityType.rawValue, groupIdentifier: nil, title: title, text: summary, tintColor: Colors.green.color, resultResettable: true, schedule: schedule, userInfo: nil, optional: false)
        
        return activity
    }
    
    // MARK: Assessment
    
    func task() -> ORKTask {
        var steps = [ORKStep]()
        
        let step = ORKFormStep(identifier:"GeneralHealthForm", title: "General Health", text: "")
        step.isOptional = false
        
        //HEALTH TODAY
        let formItemGeneralHealthSection = ORKFormItem(sectionTitle: " ") ////////// SECTION
        let generalHealthScaleAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 10,
                                                                   minimumValue: 0,
                                                                   defaultValue: -1,
                                                                   step: 1,
                                                                   vertical: false,
                                                                   maximumValueDescription: NSLocalizedString("Excellent", comment: ""),
                                                                   minimumValueDescription: NSLocalizedString("Poor", comment: ""))
        let formItemGeneralHealth = ORKFormItem(identifier:"GeneralHealth", text: NSLocalizedString("1. In general, would you say your health today is", comment: ""), answerFormat: generalHealthScaleAnswerFormat)
        formItemGeneralHealth.isOptional = false
        
        //HEALTH Comparison TODAY
        let formItemGeneralHealthComparisonSection = ORKFormItem(sectionTitle: " ") ////////// SECTION
        let generalHealthComparisonScaleAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 10,
                                                                             minimumValue: 0,
                                                                             defaultValue: -1,
                                                                             step: 1,
                                                                             vertical: false,
                                                                             maximumValueDescription: NSLocalizedString("Much better", comment: ""),
                                                                             minimumValueDescription: NSLocalizedString("Much worse", comment: ""))
        let formItemGeneralHealthComparison = ORKFormItem(identifier:"GeneralHealthComparison", text: NSLocalizedString("2. Compared to yesterday, how would you rate your health in general now?", comment: ""), answerFormat: generalHealthComparisonScaleAnswerFormat)
        
        formItemGeneralHealthComparison.isOptional = false
        
        
        //Health Limitation
        let formItemActivityLimitationSection = ORKFormItem(sectionTitle: " ") ////////// SECTION
        let activityLimitationScaleAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 10,
                                                           minimumValue: 0,
                                                           defaultValue: -1,
                                                           step: 1,
                                                           vertical: false,
                                                           maximumValueDescription: NSLocalizedString("Yes, limited a lot", comment: ""),
                                                           minimumValueDescription: NSLocalizedString("No, not limited at all", comment: ""))
        let formItemActivityLimitation = ORKFormItem(identifier:"ActivityLimitationItem", text: NSLocalizedString("3. Does your health now limit you in your activities?", comment: ""), answerFormat: activityLimitationScaleAnswerFormat)
        formItemActivityLimitation.isOptional = false
        
        
        //STRESS
        let formItemStressSection = ORKFormItem(sectionTitle: " ") ////////// SECTION
        let stressScaleAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 10,
                                                            minimumValue: 0,
                                                            defaultValue: -1,
                                                            step: 1,
                                                            vertical: false,
                                                            maximumValueDescription: NSLocalizedString("Very High Stress", comment: ""),
                                                            minimumValueDescription: NSLocalizedString("No Stress", comment: ""))
        let formItemStress = ORKFormItem(identifier:"StressItem", text: NSLocalizedString("4. How would you rate your stress today?", comment: ""), answerFormat: stressScaleAnswerFormat)
        formItemStress.isOptional = false
        
        
        //SLEEP Quality
        let formItemSleepSection = ORKFormItem(sectionTitle: " ") ////////// SECTION
        let sleepScaleAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 10,
                                                           minimumValue: 0,
                                                           defaultValue: -1,
                                                           step: 1,
                                                           vertical: false,
                                                           maximumValueDescription: NSLocalizedString("Excellent", comment: ""),
                                                           minimumValueDescription: NSLocalizedString("Poor", comment: ""))
        let formItemSleep = ORKFormItem(identifier:"SleepQualityItem", text: NSLocalizedString("5. How would you rate the quality of sleep that you got last night?", comment: ""), answerFormat: sleepScaleAnswerFormat)
        //formItemSleep.placeholder = NSLocalizedString("Enter number", comment: "")
        formItemSleep.isOptional = false
        
        //Hours of SLEEP
        let formItemSleepHoursSection = ORKFormItem(sectionTitle: " ") ////////// SECTION
        let sleepHoursScaleAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 12,
                                                           minimumValue: 0,
                                                           defaultValue: -1,
                                                           step: 1,
                                                           vertical: false,
                                                           maximumValueDescription: NSLocalizedString("", comment: ""),
                                                           minimumValueDescription: NSLocalizedString("", comment: ""))
        let formItemSleepHours = ORKFormItem(identifier:"SleepHoursItem", text: NSLocalizedString("6. How many hours of sleep did you get last night?", comment: ""), answerFormat: sleepHoursScaleAnswerFormat)
        formItemSleepHours.isOptional = false
        
        step.formItems = [
            
            formItemGeneralHealthSection,
            formItemGeneralHealth,
            
            formItemGeneralHealthComparisonSection,
            formItemGeneralHealthComparison,
            
            formItemActivityLimitationSection,
            formItemActivityLimitation,
            
            formItemStressSection,
            formItemStress,
            
            formItemSleepSection,
            formItemSleep,
            
            formItemSleepHoursSection,
            formItemSleepHours,
            
        ]
        steps += [step]
        
        
        // Create an ordered task with a single question.
        let task = ORKOrderedTask(identifier: activityType.rawValue, steps: steps)
        let taskDefault = UserDefaults()
        taskDefault.set("YES", forKey: "vasKey")
        
        return task
    }
}

