//
//  Menstruation.swift
//  TRU-Pain
//
//  Created by jonas002 on 11/4/16.
//  Copyright © 2016 Jude Jonassaint. All rights reserved.
//

import ResearchKit
import CareKit

/**
 Struct that conforms to the `Assessment` protocol to define a mood
 assessment.
 */
struct Menstruation: Assessment {
    // MARK: Activity
    
    let activityType: ActivityType = .menstruation
    
    func carePlanActivity() -> OCKCarePlanActivity {
        // Create a weekly schedule.
        let startDate = DateComponents(year: 2017, month: 01, day: 01)
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [1, 1, 1, 1, 1, 1, 1])
        
        // Get the localized strings to use for the assessment.
        let title = NSLocalizedString("Menstruation", comment: "")
        
        
        let activity = OCKCarePlanActivity.assessment(
            withIdentifier: activityType.rawValue,
            groupIdentifier: "grpMenstruation",
            title: title,
            text: nil,
            tintColor: Colors.blue.color,
            resultResettable: true,
            schedule: schedule, userInfo: nil, thresholds: nil, optional: false
        )
        
        return activity
    }
    
    // MARK: Assessment
    
    func task() -> ORKTask {
        
        
        //        let menstruatingQuestionStepTitle = "Are you menstruating?"
        //        let menstruatingTextChoices = [
        //            ORKTextChoice(text: "No", value: 0 as NSCoding & NSCopying & NSObjectProtocol),
        //            ORKTextChoice(text: "Yes", value: 1 as NSCoding & NSCopying & NSObjectProtocol)
        //        ]
        //        let menstruatingAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: menstruatingTextChoices)
        //        let menstruatingFormItem = ORKFormItem(identifier:"mentruationQ", text: menstruatingQuestionStepTitle, answerFormat: menstruatingAnswerFormat)
        //
        //        let menstruatingQuestionStep = ORKQuestionStep(identifier: activityType.rawValue, title: menstruatingQuestionStepTitle, answer: menstruatingAnswerFormat)
        //        menstruatingQuestionStep.isOptional = false
        
        //Determine which study this is  
//        let defaults = KeychainSwift()
//        let studyName = defaults.get("Study")
//        let studySite = defaults.get("Institution")
//        let study = (studySite?.lowercased())!+(studyName?.lowercased())!
        
        var steps = [ORKStep]()
        
        //////////////////////////////// Event actual time /////////////////////
        ////////////
        
        //URINE COLLECTION TIME
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
        
        
        
        
        //FIRST MORNING URINE
        let firstUrineQuestionStepTitle = "Did you collect your first morning urine?"
        let firstUrineTextChoices = [
            ORKTextChoice(text: "No, I did not collect urine this day", value: "No urine collected" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Yes, I collected my first morning urine", value: "First morning urine" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Yes, but it was not my first morning one", value: "Not first morning urine" as NSCoding & NSCopying & NSObjectProtocol)
        ]
        let firstUrineAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: firstUrineTextChoices)
        let firstUrineQuestionStep = ORKQuestionStep(identifier: "firstMorningUrine", title: firstUrineQuestionStepTitle, answer: firstUrineAnswerFormat)
        firstUrineQuestionStep.isOptional = false
        steps += [firstUrineQuestionStep]
        
        
        
        
        //SPOTTING
        let spottingQuestionStepTitle = "Are you spotting?"
        let spottingTextChoices = [
            ORKTextChoice(text: "No", value: "No" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Yes", value: "Yes" as NSCoding & NSCopying & NSObjectProtocol)
        ]
        let spottingAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: spottingTextChoices)
        
        
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
        let questionAbdominalCramp = NSLocalizedString("Do you have lower abdominal cramps?", comment: "")
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
        
        //PAIN DIFFERENCE
        //“Can you tell the difference between your sickle cell pain and your menstrual pain?”
        let scdPainDiffQuestionStepTitle = "Can you tell the difference between your sickle cell pain and your menstrual pain?"
        let scdPainDiffTextChoices = [
            ORKTextChoice(text: "No", value: "No" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Yes", value: "Yes" as NSCoding & NSCopying & NSObjectProtocol)
            
        ]
        let scdPainDiffAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: scdPainDiffTextChoices)
        let scdPainDiffQuestionStep = ORKQuestionStep(identifier: "differentiatesPain", title: scdPainDiffQuestionStepTitle, answer: scdPainDiffAnswerFormat)
        scdPainDiffQuestionStep.isOptional = false
        steps += [scdPainDiffQuestionStep]
        
        //PAIN DIFFERENCE 2
        //“Can you tell the difference between your sickle cell pain and your menstrual pain?”
        let scdPainDiff2QuestionStepTitle = "Is the sickle cell pain that you experience during your menstrual period the same as the sickle cell pain that you experience when you don’t have your menstrual period?"
        let scdPainDiff2TextChoices = [
            ORKTextChoice(text: "No", value: "No" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Yes", value: "Yes" as NSCoding & NSCopying & NSObjectProtocol)
            
        ]
        let scdPainDiff2AnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: scdPainDiff2TextChoices)
        let scdPainDiff2QuestionStep = ORKQuestionStep(identifier: "differentiatesSCDPainCharacter", title: scdPainDiff2QuestionStepTitle, answer: scdPainDiff2AnswerFormat)
        scdPainDiff2QuestionStep.isOptional = false
        steps += [scdPainDiff2QuestionStep]
        
        
        //MENSTRUATION FORM
        let step = ORKFormStep(identifier:"MenstruationFormText", title: "Menstrual flow", text: "")
        // A first field, for entering an integer.
        
        
        //        let instructionStep = ORKInstructionStep(identifier: "Symptom_IntroStep")
        //        instructionStep.title = "Tell us about your symptom."
        //        instructionStep.text = "In the next few steps you tell us the intensity, the start time, the status of your symptom., We will also ask you about the interventions you took and what you think are possible triggers for your symptom."
        //        steps += [instructionStep]
        
        
        
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
        
            step.formItems = [
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
        steps += [step]
        
        let task = ORKOrderedTask(identifier: activityType.rawValue, steps: steps)
        
        
        //task.setNavigationRule(rule, forTriggerStepIdentifier: booleanItem.identifier)
        return task
        
    }
}

