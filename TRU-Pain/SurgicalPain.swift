//
//  SurgicalPain.swift
//  TRU-Pain
//
//  Created by jonas002 on 8/27/17.
//  Copyright © 2017 scdi. All rights reserved.
//

import Foundation
import CareKit
import ResearchKit
import DefaultsKit

struct SurgicalPain: Assessment {
    // MARK: Activity
    
    let activityType: ActivityType = .surgicalPain
    
    func carePlanActivity() -> OCKCarePlanActivity {
        // Create a weekly schedule.
        let startDate = DateComponents(year: 2016, month: 01, day: 01)
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [1, 1, 1, 1, 1, 1, 1])
        
        // Get the localized strings to use for the assessment.
        let title = NSLocalizedString("Surgical Pain", comment: "")
        //        let summary = NSLocalizedString("Lower Back", comment: "")
        
        let activity = OCKCarePlanActivity.assessment(withIdentifier: activityType.rawValue, groupIdentifier: nil, title: title, text: "Tracker", tintColor: Colors.blue.color, resultResettable: true, schedule: schedule, userInfo: nil, optional: false)
        
        return activity
    }
    
    // MARK: Assessment
    
    func task() -> ORKTask {
        
        var steps = [ORKStep]()
        let manager = ListDataManager()
        let defaults = Defaults.shared
        let key = Key<String>("PainType")
        defaults.set("SurgicalPain", for: key)
        
        // Get the localized strings to use for the task.
        let question = NSLocalizedString("Rate your surgical pain?", comment: "")
        let maximumValueDescription = NSLocalizedString("Worst ever", comment: "")
        let minimumValueDescription = NSLocalizedString("None", comment: "")
        
        // Create a question and answer format.
        let answerFormat = ORKAnswerFormat.continuousScale(
            withMaximumValue: 10.0,
            minimumValue: 0.0,
            defaultValue: -1,
            maximumFractionDigits: 1,
            vertical: false,
            maximumValueDescription: maximumValueDescription,
            minimumValueDescription: minimumValueDescription
        )
        
        let questionStep = ORKQuestionStep(identifier: activityType.rawValue, title: question, answer: answerFormat)
        questionStep.isOptional = false
        steps += [questionStep]
        
        
        
        //Affected body locations
        
        let bodyLocationArray: Array = manager.getArrayFor(string: "Body Locations")
        var bodyLocationChoices:[ORKTextChoice] = []
        for item in bodyLocationArray {
            let textString = item
            let choice =    ORKTextChoice(text: textString, value:textString as NSCoding & NSCopying & NSObjectProtocol)
            bodyLocationChoices.append(choice)
        }
        
        let choiceM =    ORKTextChoice(text: "None", value:"None" as NSCoding & NSCopying & NSObjectProtocol)
        bodyLocationChoices.insert(choiceM, at: 0)
        
        let bodyLocationQuestionStepTitle = "Affected surgical locations?"
        let bodyLocationTextChoices = bodyLocationChoices
        let bodyLocationAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .multipleChoice, textChoices: bodyLocationTextChoices)
        let bodyLocationQuestionStep = ORKQuestionStep(identifier: "scdPain_affected_body_locations", title: bodyLocationQuestionStepTitle, answer: bodyLocationAnswerFormat)
        bodyLocationQuestionStep.isOptional = false
        steps += [bodyLocationQuestionStep]
        
        
        //Symptom Status
        let symptomStatusQuestionStepTitle = "Compare to your usual surgical pain, how is this one?"
        let symptomStatusTextChoices = [
            ORKTextChoice(text: "Less", value: "Less" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Same", value: "Same" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Worse", value: "Better" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Unbearable", value: "Unbearable" as NSCoding & NSCopying & NSObjectProtocol),
            ]
        
        let symptomStatusAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: symptomStatusTextChoices)
        let symptomStatusQuestionStep = ORKQuestionStep(identifier: "scdPain_status", title: symptomStatusQuestionStepTitle, answer: symptomStatusAnswerFormat)
        symptomStatusQuestionStep.isOptional = false
        steps += [symptomStatusQuestionStep]
        
        let spottingQuestionStepTitle = "Are you having non-surgical pain?"
        let spottingTextChoices = [
            ORKTextChoice(text: "No", value: 0 as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Yes", value: 1 as NSCoding & NSCopying & NSObjectProtocol)
        ]
        let spottingAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: spottingTextChoices)
        let spottingQuestionStep = ORKQuestionStep(identifier: "nonscdPain", title: spottingQuestionStepTitle, answer: spottingAnswerFormat)
        spottingQuestionStep.isOptional = false
        steps += [spottingQuestionStep]
        
        //TIME STAMP
        let h = Helpers()
        let pickerInitialDate:Date = h.currentDatePickerDate()
        
        let eventTimeStampStep = ORKFormStep(identifier:"scdPain_eventTimeStamp", title: "Time", text: "")
        // A second field, for entering a time interval.
        let eventDateItemText = NSLocalizedString("What is the time you are reporting about?", comment: "")
        let eventDateItem = ORKFormItem(identifier:"scdPain_eventTimeStamp", text:eventDateItemText, answerFormat: ORKDateAnswerFormat.dateTime(withDefaultDate: pickerInitialDate, minimumDate: nil, maximumDate: nil, calendar: Calendar.current))
        eventDateItem.placeholder = NSLocalizedString("Tap to select", comment: "")
        eventTimeStampStep.formItems = [
            eventDateItem
        ]
        eventTimeStampStep.isOptional = false
        steps += [eventTimeStampStep]
        
        
        // Create an ordered task with a single question.
        let task = ORKOrderedTask(identifier: activityType.rawValue, steps: steps)
        
        return task
    }
}
