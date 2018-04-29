//
//  MenstruationVOPAM.swift
//  TRU-Pain
//
//  Created by jonas002 on 9/28/17.
//  Copyright © 2017 scdi. All rights reserved.
//

import ResearchKit
import CareKit

/**
 Struct that conforms to the `Assessment` protocol to define a mood
 assessment.
 */
struct MenstruationVOPAM: Assessment {
    // MARK: Activity
    
    let activityType: ActivityType = .menstruationVOPAM
    
    func carePlanActivity() -> OCKCarePlanActivity {
        // Create a weekly schedule.
        let startDate = DateComponents(year: 2017, month: 01, day: 01)
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [1, 1, 1, 1, 1, 1, 1])
        
        // Get the localized strings to use for the assessment.
        let title = NSLocalizedString("Menstruation VOPAM", comment: "")
        
        
        let activity = OCKCarePlanActivity.assessment(
            withIdentifier: activityType.rawValue,
            groupIdentifier: "grpMenstruationSCD",
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
        

        
        //MIGRAINE
        let migraineQuestionStepTitle = "Over the past 24 hours have you experienced a migraine?"
        let migraineAnswerFormat = ORKBooleanAnswerFormat()
        let migraineQuestionStep = ORKQuestionStep(identifier: "migraine", title: migraineQuestionStepTitle, answer: migraineAnswerFormat)
        migraineQuestionStep.isOptional = false
        steps += [migraineQuestionStep]
        
        
        //SPOTTING
        let spottingQuestionStepTitle = "Are you spotting?"
        let spottingAnswerFormat = ORKBooleanAnswerFormat()
        let spottingQuestionStep = ORKQuestionStep(identifier: "spotting", title: spottingQuestionStepTitle, answer: spottingAnswerFormat)
        spottingQuestionStep.isOptional = false
        steps += [spottingQuestionStep]
        
        
        //MENSTRUATING
        let menstruatingQuestionStepTitle = "Are you menstruating?"
        let menstruatingTextChoices = [
            ORKTextChoice(text: "No", value: "No" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Started today", value: "Started today" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Ongoing", value: "Ongoing" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Ended yesterday", value: "Ended yesterday" as NSCoding & NSCopying & NSObjectProtocol)
        ]
        let menstruatingAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: menstruatingTextChoices)
        let menstruatingQuestionStep = ORKQuestionStep(identifier: "menstruating", title: menstruatingQuestionStepTitle, answer: menstruatingAnswerFormat)
        menstruatingQuestionStep.isOptional = false
        steps += [menstruatingQuestionStep]
        
        
        //ABDOMINAL CRAMPS
        let questionAbdominalCramp = NSLocalizedString("Do you have lower abdominal cramps? Scale 0-10 with 0 meaning “none” and 10 meaning “worst ever", comment: "")
        let maximumValueDescription = NSLocalizedString("Worst ever", comment: "")
        let minimumValueDescription = NSLocalizedString("None", comment: "")
        
        // Create a questionAbdominalCramp and answer format.
        let answerFormatAbdominalCramp = ORKAnswerFormat.continuousScale(
            withMaximumValue: 10.0,
            minimumValue: 0.0,
            defaultValue: -1,
            maximumFractionDigits: 1,
            vertical: false,
            maximumValueDescription: maximumValueDescription,
            minimumValueDescription: minimumValueDescription
        )
        
        let questionAbdominalCrampStep = ORKQuestionStep(identifier: "lowerAbdominalCramp", title: questionAbdominalCramp, answer: answerFormatAbdominalCramp)
        questionAbdominalCrampStep.isOptional = false
        steps += [questionAbdominalCrampStep]
        
        
        
        //5. MENSTRUATION PAD FORM
        let menstruationPadStep = ORKFormStep(identifier:"MenstruationFormText", title: "Menstrual Flow Collected", text: "")
        
        let formItemPad = ORKFormItem(sectionTitle: "Pads")
        let formItem01Text = NSLocalizedString(" ", comment: "")
        let formItem01 = ORKFormItem(identifier:"pad01", text: formItem01Text, answerFormat: ORKAnswerFormat.integerAnswerFormat(withUnit: nil))
        formItem01.placeholder = NSLocalizedString("Enter number", comment: "")
        
        // A second field, for entering a time interval.
        let formItem02Text = NSLocalizedString(" ", comment: "")
        let formItem02 = ORKFormItem(identifier: "pad02", text: formItem02Text, answerFormat: ORKAnswerFormat.integerAnswerFormat(withUnit: nil))
        formItem02.placeholder = NSLocalizedString("Enter number", comment: "")
        
        // A second field, for entering a time interval.
        let formItem03Text = NSLocalizedString(" ", comment: "some comment")
        let formItem03 = ORKFormItem(identifier: "pad03", text: formItem03Text, answerFormat: ORKAnswerFormat.integerAnswerFormat(withUnit: nil))
        formItem03.placeholder = NSLocalizedString("Enter number", comment: "")
        
        let formItemTampon = ORKFormItem(sectionTitle: "Tampons")
        
        let formItem04Text = NSLocalizedString(" ", comment: "")
        let formItem04 = ORKFormItem(identifier:"tampon01", text: formItem04Text, answerFormat: ORKAnswerFormat.integerAnswerFormat(withUnit: nil))
        formItem04.placeholder = NSLocalizedString("Enter number", comment: "")
        
        // A second field, for entering a time interval.
        let formItem05Text = NSLocalizedString(" ", comment: "")
        let formItem05 = ORKFormItem(identifier: "tampon02", text: formItem05Text, answerFormat: ORKAnswerFormat.integerAnswerFormat(withUnit: nil))
        formItem05.placeholder = NSLocalizedString("Enter number", comment: "")
        
        // A second field, for entering a time interval.
        let formItem06Text = NSLocalizedString(" ", comment: "some comment")
        let formItem06 = ORKFormItem(identifier: "tampon03", text: formItem06Text, answerFormat: ORKAnswerFormat.integerAnswerFormat(withUnit: nil))
        formItem06.placeholder = NSLocalizedString("Enter number", comment: "")
        
        menstruationPadStep.formItems = [
            //            birthdateItem,
            //booleanItem, //this is the main menstruation question
            formItemPad,
            
            formItem01,
            //padFormItem,
            
            formItem02,
            //pad2FormItem,
            
            formItem03,
            //pad3FormItem,
            
            formItemTampon,
            
            formItem04,
            //tampon1FormItem,
            
            formItem05,
            //tampon2FormItem,
            
            formItem06,
            //tampon3FormItem
            
        ]
        steps += [menstruationPadStep]
        
        
        //MENSTRUATION FLOW FORM
        let menstruationFlowStep = ORKFormStep(identifier:"MenstruationFlowFormText", title: "Menstrual Flow", text: "")
        let flowAnswerFormat = ORKBooleanAnswerFormat()
        
        //let flowSectionItem01 = ORKFormItem(sectionTitle: "a. Have you experienced bleeding that soaks through 1 or more tampons or pads every hour for several hours in a row?")
        let flowItem01 = ORKFormItem(identifier:"flow01", text: "a. Have you experienced bleeding that soaks through 1 or more tampons or pads every hour for several hours in a row?", answerFormat: flowAnswerFormat)
        flowItem01.isOptional = false
        
        let flowSectionItem02 = ORKFormItem(sectionTitle: " ")
        let flowItem02 = ORKFormItem(identifier:"flow02", text: "b. Do you need to wear more than one pad at a time to control menstrual flow?", answerFormat: flowAnswerFormat)
        flowItem02.isOptional = false
        
        let flowSectionItem03 = ORKFormItem(sectionTitle: " ")
        let flowItem03 = ORKFormItem(identifier:"flow03", text: "c. Do you need to change pads or tampons at night?", answerFormat: flowAnswerFormat)
        flowItem03.isOptional = false
        
        let flowSectionItem04 = ORKFormItem(sectionTitle: "")
        let flowItem04 = ORKFormItem(identifier:"flow04", text: "d. Do you have menstrual flow with blood clots that are as big as a quarter or larger?", answerFormat: flowAnswerFormat)
        flowItem04.isOptional = false
        
        menstruationFlowStep.isOptional = false
        
        menstruationFlowStep.formItems = [
            //flowSectionItem01,
            flowItem01,
            
            flowSectionItem02,
            flowItem02,
            
            flowSectionItem03,
            flowItem03,
            
            flowSectionItem04,
            flowItem04
        ]
        steps += [menstruationFlowStep]
        
//        let predicate = ORKResultPredicate.predicateForBooleanQuestionResult(
//            with: ORKResultSelector(resultIdentifier: firstUrineQuestionStep.identifier), expectedAnswer: false)
        let predicateNo = ORKResultPredicate.predicateForChoiceQuestionResult(with: ORKResultSelector(resultIdentifier: menstruatingQuestionStep.identifier), matchingPattern: "No")
        let predicateEndedYesterday = ORKResultPredicate.predicateForChoiceQuestionResult(with: ORKResultSelector(resultIdentifier: menstruatingQuestionStep.identifier), matchingPattern: "Ended yesterday")
        
        let rule = ORKPredicateStepNavigationRule(
            resultPredicatesAndDestinationStepIdentifiers: [(predicateNo, ORKNullStepIdentifier),(predicateEndedYesterday, ORKNullStepIdentifier)])
        
        let task = ORKNavigableOrderedTask(identifier: activityType.rawValue, steps: steps)
        task.setNavigationRule(rule, forTriggerStepIdentifier: menstruatingQuestionStep.identifier)
      
        return task
        
    }
}
