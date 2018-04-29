//
//  Stool.swift
//  TRU-Care
//
//  Created by scdi on 6/3/16.
//  Copyright © 2016 scdi. All rights reserved.
//

import ResearchKit
import CareKit

/**
 Struct that conforms to the `Assessment` protocol to define a mood
 assessment.
 */
struct Stool: Assessment {
    // MARK: Activity
    
    let activityType: ActivityType = .stool
    
    func carePlanActivity() -> OCKCarePlanActivity {
        // Create a weekly schedule.
        let startDate = DateComponents(year: 2017, month: 01, day: 01)
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [1, 1, 1, 1, 1, 1, 1])
        
        // Get the localized strings to use for the assessment.
        let title = NSLocalizedString("Stools", comment: "")
        let summary = NSLocalizedString("Count", comment: "")
        
        let activity = OCKCarePlanActivity.assessment(
            withIdentifier: activityType.rawValue,
            groupIdentifier: nil,
            title: title,
            text: summary,
            tintColor: Colors.yellow.color,
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
        let question = NSLocalizedString("How many NORMAL stool did you have today?", comment: "")
        let maximumValueDescription = NSLocalizedString("or more", comment: "")
        let minimumValueDescription = NSLocalizedString("None", comment: "")
        
        // Create a question and answer format.
        let answerFormat = ORKScaleAnswerFormat(
            maximumValue: 5,
            minimumValue: 0,
            defaultValue: -1,
            step: 1,
            vertical: false,
            maximumValueDescription: maximumValueDescription,
            minimumValueDescription: minimumValueDescription
        )
        
        let questionStep = ORKQuestionStep(identifier: "normal stool", title: question, answer: answerFormat)
        questionStep.isOptional = false
        
        
        let questionDiarrhea = NSLocalizedString("How many Diarrhea stool did you have today?", comment: "")
        let maximumValueDescriptionDiarrhea = NSLocalizedString("or more", comment: "")
        let minimumValueDescriptionDiarrhea = NSLocalizedString("None", comment: "")
        
        // Create a question and answer format.
        let answerFormatDiarrhea = ORKScaleAnswerFormat(
            maximumValue: 10,
            minimumValue: 0,
            defaultValue: -1,
            step: 1,
            vertical: false,
            maximumValueDescription: maximumValueDescriptionDiarrhea,
            minimumValueDescription: minimumValueDescriptionDiarrhea
        )
        
        let questionStepDiarrhea = ORKQuestionStep(identifier: "diarrhea stool", title: questionDiarrhea, answer: answerFormatDiarrhea)
        questionStepDiarrhea.isOptional = false
        
        
        // Create an ordered task with a single question.
        let task = ORKOrderedTask(identifier: activityType.rawValue, steps: [questionStep, questionStepDiarrhea])
        
        return task
    }

}
