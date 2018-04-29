//
//  Temperature.swift
//  TRU-Pain
//
//  Created by jonas002 on 12/10/16.
//  Copyright © 2016 Jude Jonassaint. All rights reserved.
//

import ResearchKit
import CareKit



struct Temperature: Assessment {
    // MARK: Activity
    
    let activityType: ActivityType = .temperature
    
    func carePlanActivity() -> OCKCarePlanActivity {
        // Create a weekly schedule.
        let startDate = DateComponents(year: 2017, month: 01, day: 01)
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [1, 1, 1, 1, 1, 1, 1])
        
        // Get the localized strings to use for the assessment.
        let title = NSLocalizedString("Temperature", comment: "")
        let summary = NSLocalizedString("Oral", comment: "")
        
        let activity = OCKCarePlanActivity.assessment(
            withIdentifier: activityType.rawValue,
            groupIdentifier: nil,
            title: title,
            text: summary,
            tintColor: Colors.purple.color,
            resultResettable: true,
            schedule: schedule,
            userInfo: nil,
            optional: false
        )
        
        return activity
    }
    
    // MARK: Assessment
    
    func task() -> ORKTask {
        // Get the localized strings to use for the task.
        let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyTemperature)!
        let unit = HKUnit(from: "degF")
        let answerFormat = ORKHealthKitQuantityTypeAnswerFormat(quantityType: quantityType, unit: unit, style: .decimal)
        
        // Create a question.
        let title = NSLocalizedString("Input your temperature", comment: "")
        let questionStep = ORKQuestionStep(identifier: activityType.rawValue, title: title, answer: answerFormat)
        questionStep.isOptional = false
        
        
        //TIME STAMP
        let eventTimeStampStep = ORKFormStep(identifier:"temperature_eventTimeStampFormText", title: "Time", text: "")
        // A second field, for entering a time interval.
        let eventDateItemText = NSLocalizedString("What is the time you are reporting about?", comment: "")
        let eventDateItem = ORKFormItem(identifier:"temperature_eventTimeStamp", text:eventDateItemText, answerFormat: ORKDateAnswerFormat.dateTime())
        eventDateItem.placeholder = NSLocalizedString("Tap to select", comment: "")
        eventTimeStampStep.formItems = [
            eventDateItem
        ]
        eventTimeStampStep.isOptional = false
        
        
        // Create an ordered task with a single question.
        let task = ORKOrderedTask(identifier: activityType.rawValue, steps: [questionStep,eventTimeStampStep])
        
        return task
    }
}
//let temperatureActivity = OCKCarePlanActivity.assessment(withIdentifier: ActivityIdentifier.temperature.rawValue,
//                groupIdentifier: nil,
//                title: "Temperature",
//                text: "Oral",
//                tintColor: UIColor.darkYellow(),
//                resultResettable: true,
//                schedule: CarePlanData.dailyScheduleRepeating(occurencesPerDay: 1),
//                userInfo: ["ORKTask": AssessmentTaskFactory.makeTemperatureAssessmentTask()])
