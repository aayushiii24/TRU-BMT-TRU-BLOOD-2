//
//  SymptomFocus.swift
//  TRU-Pain
//
//  Created by jonas002 on 11/27/16.
//  Copyright © 2016 Jude Jonassaint. All rights reserved.
//

import ResearchKit
import CareKit
import CoreData



/**
 Struct that conforms to the `Assessment` protocol to define a mood
 assessment.
 */
struct SymptomFocus: Assessment {
    // MARK: Activity
    
    let activityType: ActivityType = .symptomFocus
    
    
    
    
    
    func carePlanActivity() -> OCKCarePlanActivity {
        
        
        // Create a weekly schedule.
        let startDate = DateComponents(year: 2017, month: 01, day: 01)
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [1, 1, 1, 1, 1, 1, 1])
        
        // Get the localized strings to use for the assessment.
        let title = NSLocalizedString("Symptom", comment: "")
        let summary = NSLocalizedString("Tracker", comment: "")
        
        let activity = OCKCarePlanActivity.assessment(
            withIdentifier: activityType.rawValue,
            groupIdentifier: nil,
            title: title,
            text: summary,
            tintColor: Colors.blue.color,
            resultResettable: true,
            schedule: schedule,
            userInfo: nil,
            optional: false
        )
        
        return activity
    }
    
    // MARK: Assessment
    
    func task() -> ORKTask {
        
        var steps = [ORKStep]()
        let manager = ListDataManager()
        
        //        //add instructions step
        //        let instructionStep = ORKInstructionStep(identifier: "Symptom_IntroStep")
        //        instructionStep.title = "Tell us about your symptom."
        //        instructionStep.text = "In the next few steps you tell us the intensity, the start time, the status of your symptom., We will also ask you about the interventions you took and what you think are possible triggers for your symptom."
        //        steps += [instructionStep]
        
        
        
        let symptomArray: Array = manager.getArrayFor(string: "Symptoms")
        var choices:[ORKTextChoice] = []
        for item in symptomArray {
            let textString = item
            let choice =    ORKTextChoice(text: textString, value:textString as NSCoding & NSCopying & NSObjectProtocol)
            choices.append(choice)
        }
        
        //SYMPTOM
        let spottingQuestionStepTitle = "What is your symptom?"
        let spottingTextChoices = choices
        let spottingAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: spottingTextChoices)
        
        
        let spottingQuestionStep = ORKQuestionStep(identifier: "symptom_focus", title: spottingQuestionStepTitle, answer: spottingAnswerFormat)
        spottingQuestionStep.isOptional = false
        steps += [spottingQuestionStep]
        
        //Symptom Status
        let symptomStatusQuestionStepTitle = "Is your symptom?"
        let symptomStatusTextChoices = [
            
            ORKTextChoice(text: "New", value: "New" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Resolved", value: "Resolved" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Better", value: "Better" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Same", value: "Same" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Worse", value: "Worse" as NSCoding & NSCopying & NSObjectProtocol)
        ]
        
        let symptomStatusAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: symptomStatusTextChoices)
        let symptomStatusQuestionStep = ORKQuestionStep(identifier: "symptom_status", title: symptomStatusQuestionStepTitle, answer: symptomStatusAnswerFormat)
        symptomStatusQuestionStep.isOptional = false
        steps += [symptomStatusQuestionStep]
        
        
        
        //Symptom Intensity
        let intensityLevelAnswerFormat = ORKAnswerFormat.continuousScale(
            withMaximumValue: 10.0,
            minimumValue: 0.0,
            defaultValue: -1,
            maximumFractionDigits: 1,
            vertical: false,
            maximumValueDescription: "Worst",
            minimumValueDescription: "None")
        let intensityLevelQuestionStepTitle = "On a scale of 0-10, how intense is your symptom?"
        let intensityLevelQuestionStep = ORKQuestionStep(identifier: "symptom_intensity_level", title: intensityLevelQuestionStepTitle, answer: intensityLevelAnswerFormat)
        intensityLevelQuestionStep.isOptional = false
        steps += [intensityLevelQuestionStep]
        
        
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
        //let bodyLocationQuestionStepTitle = "Affected body locations?"
        let bodyLocationTextChoices = bodyLocationChoices
        let bodyLocationAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .multipleChoice, textChoices: bodyLocationTextChoices)
        //let bodyLocationQuestionStep = ORKQuestionStep(identifier: "symptom_affected_body_locations", title: bodyLocationQuestionStepTitle, answer: bodyLocationAnswerFormat)
        //bodyLocationQuestionStep.isOptional = false
        //steps += [bodyLocationQuestionStep]
        
        let step = ORKFormStep(identifier: "other_body_locations", title: "Select affected body locations, if any.", text: "")
        let formItem01Text = NSLocalizedString("", comment: "")
        let formItem01 = ORKFormItem(identifier: "other_locations", text: formItem01Text, answerFormat: ORKAnswerFormat.textAnswerFormat(withMaximumLength: 120))
        formItem01.placeholder = NSLocalizedString("Tap to specify other locations", comment: "")
        let formItem02 = ORKFormItem(identifier: "symptom_affected_body_locations", text: "", answerFormat:bodyLocationAnswerFormat )
        
        step.formItems = [formItem02,formItem01]
        steps += [step]
        
        
        //Interventions
        let interventionArray: Array = manager.getArrayFor(string: "Interventions")
        var interventionChoices:[ORKTextChoice] = []
        for item in interventionArray {
            let textString = item
            let choice =    ORKTextChoice(text: textString, value:textString as NSCoding & NSCopying & NSObjectProtocol)
            interventionChoices.append(choice)
        }
        let choiceN =    ORKTextChoice(text: "None", value:"None" as NSCoding & NSCopying & NSObjectProtocol)
        interventionChoices.insert(choiceN, at: 0)
        //        let choiceNN =    ORKTextChoice(text: "Other", value:"Other" as NSCoding & NSCopying & NSObjectProtocol)
        //        interventionChoices.append(choiceNN)
        
        //let interventionQuestionStepTitle = "Interventions?"
        let interventionsTextChoices = interventionChoices
        let interventionsAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .multipleChoice, textChoices: interventionsTextChoices)
        
        let stepInterventions = ORKFormStep(identifier: "Other Interventions", title: "Select interventions done, if any.", text: "")
        let formItem01TextInterventions = NSLocalizedString("", comment: "")
        let formItem01Interventions = ORKFormItem(identifier: "other_interventions", text: formItem01TextInterventions, answerFormat: ORKAnswerFormat.textAnswerFormat(withMaximumLength: 120))
        formItem01Interventions.placeholder = NSLocalizedString("Tap to specify other interventions", comment: "")
        let formItem02Interventions = ORKFormItem(identifier: "symptom_interventions", text: "", answerFormat:interventionsAnswerFormat)
        
        stepInterventions.formItems = [formItem02Interventions,formItem01Interventions]
        steps += [stepInterventions]
        //        let interventionQuestionStep = ORKQuestionStep(identifier: "symptom_interventions", title: interventionQuestionStepTitle, answer: interventionAnswerFormat)
        //        interventionQuestionStep.isOptional = false
        //        steps += [interventionQuestionStep]
        
        
        //triggers
        //let triggerString = keychain.get("Triggers")
        let triggerArray: Array = manager.getArrayFor(string: "Triggers")
        var triggerChoices:[ORKTextChoice] = []
        for item in triggerArray {
            let textString = item
            let choice =    ORKTextChoice(text: textString, value:textString as NSCoding & NSCopying & NSObjectProtocol)
            triggerChoices.append(choice)
        }
        //        let choiceOOO =    ORKTextChoice(text: "Not applicable", value:"Not applicable" as NSCoding & NSCopying & NSObjectProtocol)
        //        triggerChoices.insert(choiceOOO, at:0)
        let choiceO =    ORKTextChoice(text: "None", value:"None" as NSCoding & NSCopying & NSObjectProtocol)
        triggerChoices.insert(choiceO, at: 1)
        //        let choiceDK =    ORKTextChoice(text: "Don't know", value:"Don't know" as NSCoding & NSCopying & NSObjectProtocol)
        //        triggerChoices.insert(choiceDK, at:2)
        //
        //        let choiceOO =    ORKTextChoice(text: "Other", value:"Other" as NSCoding & NSCopying & NSObjectProtocol)
        //        triggerChoices.append(choiceOO)
        //
        
        
        //let triggerQuestionStepTitle = "Triggers"
        let triggersTextChoices = triggerChoices
        let triggersAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .multipleChoice, textChoices: triggersTextChoices)
        
        
        let stepTriggers = ORKFormStep(identifier: "Other Triggers", title: "Select triggers, if any.", text: "")
        let formItem01TextTriggers = NSLocalizedString("", comment: "")
        let formItem01Triggers = ORKFormItem(identifier: "other_triggers", text: formItem01TextTriggers, answerFormat: ORKAnswerFormat.textAnswerFormat(withMaximumLength: 120))
        formItem01Triggers.placeholder = NSLocalizedString("Tap to specify other triggers", comment: "")
        let formItem02Triggers = ORKFormItem(identifier: "symptom_triggers", text: "", answerFormat:triggersAnswerFormat )
        
        stepTriggers.formItems = [formItem02Triggers,formItem01Triggers]
        steps += [stepTriggers]
        
        //        let triggerQuestionStep = ORKQuestionStep(identifier: "symptom_triggers", title: triggerQuestionStepTitle, answer: triggerAnswerFormat)
        //        triggerQuestionStep.isOptional = false
        //        steps += [triggerQuestionStep]
        
        //TIME STAMP
        let eventTimeStampStep = ORKFormStep(identifier:"symptom_eventTimeStamp", title: "Time", text: "")
        // A second field, for entering a time interval.
        let eventDateItemText = NSLocalizedString("What is the time you are reporting about?", comment: "")
        let eventDateItem = ORKFormItem(identifier:"symptom_eventTimeStamp", text:eventDateItemText, answerFormat: ORKDateAnswerFormat.dateTime())
        eventDateItem.placeholder = NSLocalizedString("Tap to select", comment: "")
        eventTimeStampStep.formItems = [
            eventDateItem
        ]
        eventTimeStampStep.isOptional = false
        steps += [eventTimeStampStep]
        
        
        let symptomDefault = UserDefaults()
        symptomDefault.set("YES", forKey: "symptomKey")
        
        // Create an ordered task with a single question.
        let task = ORKOrderedTask(identifier: activityType.rawValue, steps: steps)
        
        return task
    }
}

