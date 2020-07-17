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
struct StoolConsistency: Assessment {
    // MARK: Activity
    
    let activityType: ActivityType = .stoolConsistency
    
    func carePlanActivity() -> OCKCarePlanActivity {
        // Create a weekly schedule.
        let startDate = DateComponents(year: 2016, month: 01, day: 01)
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [1, 1, 1, 1, 1, 1, 1])
        
        // Get the localized strings to use for the assessment.
        let title = NSLocalizedString("Stools", comment: "")
        let summary = NSLocalizedString("Today", comment: "")
        
        
        let activity = OCKCarePlanActivity.assessment(withIdentifier: activityType.rawValue, groupIdentifier: nil, title: title, text: summary, tintColor: Colors.mediumBlue.color, resultResettable: true, schedule: schedule, userInfo: nil, thresholds: nil, optional: false
        )
        
        
        return activity
    }
    
    // MARK: Assessment
    
    func task() -> ORKTask {
        
        
        var steps = [ORKStep]()
        
        //////////////////////////////// Event actual time /////////////////////
        ////////////
        
        //URINE COLLECTION TIME
        //TIME STAMP
        /*let eventTimeStampStep = ORKFormStep(identifier:"symptom_eventTimeStamp", title: "Time", text: "")
         // A second field, for entering a time interval.
         let eventDateItemText = NSLocalizedString("What is the time you are reporting about?", comment: "")
         let eventDateItem = ORKFormItem(identifier:"symptom_eventTimeStamp", text:eventDateItemText, answerFormat: ORKDateAnswerFormat.dateTime())
         eventDateItem.placeholder = NSLocalizedString("Tap to select", comment: "")
         eventTimeStampStep.formItems = [
         eventDateItem
         ]
         eventTimeStampStep.isOptional = false
         steps += [eventTimeStampStep]
         */
        
        
        //MENSTRUATION FORM
        let step = ORKFormStep(identifier:"StoolConsistencyFormText", title: "Stool", text: "")
        // A first field, for entering an integer.
        
        
        //        let instructionStep = ORKInstructionStep(identifier: "Symptom_IntroStep")
        //        instructionStep.title = "Tell us about your symptom."
        //        instructionStep.text = "In the next few steps you tell us the intensity, the start time, the status of your symptom., We will also ask you about the interventions you took and what you think are possible triggers for your symptom."
        //        steps += [instructionStep]
        
        step.isOptional = false
        
        let formItemConstipated = ORKFormItem(sectionTitle: "Constipated") ////////// SECTION
        
        let formItem01Text = NSLocalizedString(" ", comment: "")
        let formItem01 = ORKFormItem(identifier:"BStoolT1", text: formItem01Text, answerFormat: ORKAnswerFormat.integerAnswerFormat(withUnit: nil))
        //formItem01.placeholder = NSLocalizedString("Enter number", comment: "")
        formItem01.isOptional = true
        
        // A second field, for entering a time interval.
        let formItem02Text = NSLocalizedString(" ", comment: "")
        let formItem02 = ORKFormItem(identifier: "BStoolT2", text: formItem02Text, answerFormat: ORKAnswerFormat.integerAnswerFormat(withUnit: nil))
        //formItem02.placeholder = NSLocalizedString("0", comment: "")
        formItem02.isOptional = true
        
        let formItemNormal = ORKFormItem(sectionTitle: "Normal") ////////// SECTION
        
        // A second field, for entering a time interval.
        let formItem03Text = NSLocalizedString(" ", comment: "some comment")
        let formItem03 = ORKFormItem(identifier: "BStoolT3", text: formItem03Text, answerFormat: ORKAnswerFormat.integerAnswerFormat(withUnit: nil))
        //formItem03.placeholder = NSLocalizedString("0", comment: "")
        formItem03.isOptional = true
        
        let formItem04Text = NSLocalizedString(" ", comment: "")
        let formItem04 = ORKFormItem(identifier:"BStoolT4", text: formItem04Text, answerFormat: ORKAnswerFormat.integerAnswerFormat(withUnit: nil))
        //formItem04.placeholder = NSLocalizedString("0", comment: "")
        formItem04.isOptional = true
        
        let formItemLoose = ORKFormItem(sectionTitle: "Loose") ////////// SECTION
        // A second field, for entering a time interval.
        let formItem05Text = NSLocalizedString(" ", comment: "")
        let formItem05 = ORKFormItem(identifier: "BStoolT5", text: formItem05Text, answerFormat: ORKAnswerFormat.integerAnswerFormat(withUnit: nil))
        //formItem05.placeholder = NSLocalizedString("0", comment: "")
        formItem05.isOptional = true
        
        // A second field, for entering a time interval.
        let formItem06Text = NSLocalizedString(" ", comment: "some comment")
        let formItem06 = ORKFormItem(identifier: "BStoolT6", text: formItem06Text, answerFormat: ORKAnswerFormat.integerAnswerFormat(withUnit: nil))
        //formItem06.placeholder = NSLocalizedString("Enter number", comment: "")
        formItem06.isOptional = true
        
        let formItem07Text = NSLocalizedString(" ", comment: "some comment")
        let formItem07 = ORKFormItem(identifier: "BStoolT7", text: formItem07Text, answerFormat: ORKAnswerFormat.integerAnswerFormat(withUnit: nil))
        //formItem07.placeholder = NSLocalizedString("0", comment: "")
        formItem07.isOptional = true
        
//        formItem01.isOptional = false
//        formItem02.isOptional = false
//        formItem03.isOptional = false
//        formItem04.isOptional = false
//        formItem05.isOptional = false
//        formItem06.isOptional = false
//        formItem07.isOptional = false
        
        
        
        
        step.formItems = [
            
            //formItemConstipated,
            
            formItem01,
            //padFormItem,
            
            formItem02,
            //pad2FormItem,
            
            //formItemNormal,
            
            formItem03,
            //pad3FormItem,
            
            formItem04,
            //tampon1FormItem,
            
            //formItemLoose,
            
            formItem05,
            //tampon2FormItem,
            
            formItem06,
            //tampon3FormItem
            
            formItem07,
            //tampon3FormItem
            
        ]
        steps += [step]
        
        let task = ORKOrderedTask(identifier: activityType.rawValue, steps: steps)
        
        
        //task.setNavigationRule(rule, forTriggerStepIdentifier: booleanItem.identifier)
        return task
        
        
    }
}

