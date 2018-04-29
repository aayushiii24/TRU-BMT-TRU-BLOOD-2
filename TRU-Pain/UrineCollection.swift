//
//  UrineCollection.swift
//  TRU-Pain
//
//  Created by jonas002 on 9/27/17.
//  Copyright © 2017 scdi. All rights reserved.
//


import Foundation
import ResearchKit
import CareKit

/**
 Struct that conforms to the `Assessment` protocol to define urine collection
 assessment.
 */

struct UrineCollection: Assessment {
    // MARK: Activity
    
    let activityType: ActivityType = .urineCollection
    
    func carePlanActivity() -> OCKCarePlanActivity {
        // Create a weekly schedule.
        let startDate = DateComponents(year: 2017, month: 01, day: 01)
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [1, 1, 1, 1, 1, 1, 1])
        
        // Get the localized strings to use for the assessment.
        let title = NSLocalizedString("Urine Collection VOPAM", comment: "")
        
        
        let activity = OCKCarePlanActivity.assessment(
            withIdentifier: activityType.rawValue,
            groupIdentifier: "grpUrineColection",
            title: title,
            text: nil,
            tintColor: Colors.blue.color,
            resultResettable: true,
            schedule: schedule, userInfo: nil, optional: false)
        
        return activity
    }
    
    // MARK: Assessment
    
    func task() -> ORKTask {
        
        var steps = [ORKStep]()
        
        //FIRST MORNING URINE
        let firstUrineQuestionStepTitle = "Did you collect your morning urine?"
        let firstUrineAnswerFormat = ORKBooleanAnswerFormat()
        let firstUrineQuestionStep = ORKQuestionStep(identifier: "firstMorningUrine", title: firstUrineQuestionStepTitle, answer: firstUrineAnswerFormat)
        firstUrineQuestionStep.isOptional = false
        steps += [firstUrineQuestionStep]
        
        
        
        //URINE COLLECTION TIME
        //TIME STAMP
        let eventTimeStampStep = ORKFormStep(identifier:"UrineCollection_eventTimeStamp", title: "Time", text: "")
        // A second field, for entering a time interval.
        let eventDateItemText = NSLocalizedString("What is the time you are reporting about?", comment: "")
        let eventDateItem = ORKFormItem(identifier:"symptom_eventTimeStamp", text:eventDateItemText, answerFormat: ORKDateAnswerFormat.dateTime())
        eventDateItem.placeholder = NSLocalizedString("Tap to select", comment: "")
        eventTimeStampStep.formItems = [
            eventDateItem
        ]
        eventTimeStampStep.isOptional = false
        steps += [eventTimeStampStep]
        
     
        let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
        summaryStep.title = "We appreciate your effort!"
        summaryStep.text = ""
        steps += [summaryStep]

        
        let predicate = ORKResultPredicate.predicateForBooleanQuestionResult(
            with: ORKResultSelector(resultIdentifier: firstUrineQuestionStep.identifier), expectedAnswer: false)
        let rule = ORKPredicateStepNavigationRule(
            resultPredicatesAndDestinationStepIdentifiers: [(predicate, ORKNullStepIdentifier)])
        
        let task = ORKNavigableOrderedTask(identifier: "task", steps: steps)
        task.setNavigationRule(rule, forTriggerStepIdentifier: firstUrineQuestionStep.identifier)
        
        
        return task
        
    }
}


