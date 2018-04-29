//
//  SCDPainNotVOPAM.swift
//  TRU-Pain
//
//  Created by jonas002 on 9/28/17.
//  Copyright © 2017 scdi. All rights reserved.
//


import CareKit
import ResearchKit


/**
 Struct that conforms to the `Assessment` protocol to define a back pain
 assessment.
 */
struct SCDPainExperience: Assessment {
    // MARK: Activity
    
    let activityType: ActivityType = .scdPainExperience
    
    func carePlanActivity() -> OCKCarePlanActivity {
        // Create a weekly schedule.
        let startDate = DateComponents(year: 2016, month: 01, day: 01)
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [1, 1, 1, 1, 1, 1, 1])
        
        // Get the localized strings to use for the assessment.
        let title = NSLocalizedString("Sickle Cell Pain", comment: "")
        //        let summary = NSLocalizedString("Lower Back", comment: "")
        
        let activity = OCKCarePlanActivity.assessment(withIdentifier: activityType.rawValue, groupIdentifier: nil, title: title, text: "Tracker", tintColor: Colors.blue.color, resultResettable: true, schedule: schedule, userInfo: nil, optional: false)
        
        return activity
    }
    
    // MARK: Assessment
    
    func task() -> ORKTask {
        
        var steps = [ORKStep]()
  
        //a.Are you experiencing sickle cell pain?
        let scdPainQuestionStepTitle = "Are you experiencing sickle cell pain?"
        let scdPainAnswerFormat = ORKBooleanAnswerFormat()
        let scdPainQuestionStep = ORKQuestionStep(identifier: "scdPainIdentifier", title: scdPainQuestionStepTitle, answer: scdPainAnswerFormat)
        scdPainQuestionStep.isOptional = false
        steps += [scdPainQuestionStep]
        
        
        //i. RATE YOUR PAIN
        let avgPainQuestion = NSLocalizedString("Please rate your average pain over the past 24 hours.", comment: "")
        let avgPainMaximumValueDescription = NSLocalizedString("Worst", comment: "")
        let avgPainMimumValueDescription = NSLocalizedString("None", comment: "")
        
        let avgPainAnswerFormat = ORKAnswerFormat.continuousScale(
            withMaximumValue: 10.0,
            minimumValue: 0.0,
            defaultValue: -1,
            maximumFractionDigits: 1,
            vertical: false,
            maximumValueDescription: avgPainMaximumValueDescription,
            minimumValueDescription: avgPainMimumValueDescription
        )
        
        let avgPainQuestionStep = ORKQuestionStep(identifier: "questionAVGPainIdentifier", title: avgPainQuestion, answer: avgPainAnswerFormat)
        avgPainQuestionStep.isOptional = false
        steps += [avgPainQuestionStep]
        
        
        
        //ii. Please rate your MOST RECENT PAIN over the past 24 hours
        let mostPainQuestion = NSLocalizedString("Please rate your most recent pain over the past 24 hours.", comment: "")
        let mostPainMaximumValueDescription = NSLocalizedString("Worst", comment: "")
        let mostPainMinimumValueDescription = NSLocalizedString("None", comment: "")
        
        let mostPainAnswerFormat = ORKAnswerFormat.continuousScale(
            withMaximumValue: 10.0,
            minimumValue: 0.0,
            defaultValue: -1,
            maximumFractionDigits: 1,
            vertical: false,
            maximumValueDescription: mostPainMaximumValueDescription,
            minimumValueDescription: mostPainMinimumValueDescription
        )
        
        let mostPainQuestionStep = ORKQuestionStep(identifier: activityType.rawValue, title: mostPainQuestion, answer: mostPainAnswerFormat)
        mostPainQuestionStep.isOptional = false
        steps += [mostPainQuestionStep]
        
        
        
        //BODY LOCATIONS
        let bodyLocationTextChoices =
            [ORKTextChoice(text: "Head", value: "Head" as NSCoding & NSCopying & NSObjectProtocol),
             ORKTextChoice(text: "Neck", value: "Neck" as NSCoding & NSCopying & NSObjectProtocol),
             ORKTextChoice(text: "Chest", value: "Chest" as NSCoding & NSCopying & NSObjectProtocol),
             ORKTextChoice(text: "Back", value: "Back" as NSCoding & NSCopying & NSObjectProtocol),
             ORKTextChoice(text: "Abdomen", value: "Abdomen" as NSCoding & NSCopying & NSObjectProtocol),
             ORKTextChoice(text: "Pelvis", value: "Pelvis" as NSCoding & NSCopying & NSObjectProtocol),
             ORKTextChoice(text: "Limb", value: "Limb" as NSCoding & NSCopying & NSObjectProtocol),
             ORKTextChoice(text: "Joints", value: "Joints" as NSCoding & NSCopying & NSObjectProtocol)
        ]
        
        let bodyLocationAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .multipleChoice, textChoices: bodyLocationTextChoices)
        let bodyLocationQuestionStep = ORKQuestionStep(identifier: "scdPain_affected_body_locations", title: "Where on your body is this pain?", answer: bodyLocationAnswerFormat)
        bodyLocationQuestionStep.isOptional = false
        steps += [bodyLocationQuestionStep]
  
        
        //SCD PAIN Symptom STATUS
        let scdPainStatusQuestionStepTitle = "Compare to your usual sickle cell pain, how is this one?"
        let scdPainStatusTextChoices = [
            ORKTextChoice(text: "Less", value: "Less" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Same", value: "Same" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Worse", value: "Better" as NSCoding & NSCopying & NSObjectProtocol)
        ]
        
        let scdPainStatusAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: scdPainStatusTextChoices)
        let scdPainStatusQuestionStep = ORKQuestionStep(identifier: "scdPain_status", title: scdPainStatusQuestionStepTitle, answer: scdPainStatusAnswerFormat)
        scdPainStatusQuestionStep.isOptional = false
        steps += [scdPainStatusQuestionStep]
        
        
        //INTERVENTIONS CHOICES
        let interventionsTextChoices =
            [ORKTextChoice(text: "None", value: "None" as NSCoding & NSCopying & NSObjectProtocol),
             ORKTextChoice(text: "Deep breathing", value: "Deep breathing" as NSCoding & NSCopying & NSObjectProtocol),
             ORKTextChoice(text: "Distraction", value: "Distraction" as NSCoding & NSCopying & NSObjectProtocol),
             ORKTextChoice(text: "Drinking fluids", value: "Drinking fluids" as NSCoding & NSCopying & NSObjectProtocol),
             ORKTextChoice(text: "Keeping active", value: "Keeping active" as NSCoding & NSCopying & NSObjectProtocol),
             ORKTextChoice(text: "Medical help", value: "Medical help" as NSCoding & NSCopying & NSObjectProtocol),
             ORKTextChoice(text: "Relaxation", value: "Relaxation" as NSCoding & NSCopying & NSObjectProtocol),
             ORKTextChoice(text: "Socially connected", value: "Socially connected" as NSCoding & NSCopying & NSObjectProtocol),
             ORKTextChoice(text: "Other", value: "Other" as NSCoding & NSCopying & NSObjectProtocol)
        ]
        
        let interventionsAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .multipleChoice, textChoices: interventionsTextChoices)
        
        let stepInterventions = ORKFormStep(identifier: "Other Interventions", title: "Select interventions done, if any.", text: "")
        let formItem01TextInterventions = NSLocalizedString("", comment: "")
        let formItem01Interventions = ORKFormItem(identifier: "other_interventions", text: formItem01TextInterventions, answerFormat: ORKAnswerFormat.textAnswerFormat(withMaximumLength: 120))
        formItem01Interventions.placeholder = NSLocalizedString("Tap to specify other interventions", comment: "")
        let formItem02Interventions = ORKFormItem(identifier: "symptom_interventions", text: "", answerFormat:interventionsAnswerFormat)
        
        stepInterventions.formItems = [formItem02Interventions,formItem01Interventions]
        steps += [stepInterventions]
       
        
        
        //TRIGGERS CHOICES
        let triggersTextChoices =
            [ORKTextChoice(text: "None", value: "None" as NSCoding & NSCopying & NSObjectProtocol),
             ORKTextChoice(text: "None", value: "None" as NSCoding & NSCopying & NSObjectProtocol),
             ORKTextChoice(text: "Eating", value: "Eating" as NSCoding & NSCopying & NSObjectProtocol),
             ORKTextChoice(text: "Meds", value: "Meds" as NSCoding & NSCopying & NSObjectProtocol),
             ORKTextChoice(text: "Motion", value: "Motion" as NSCoding & NSCopying & NSObjectProtocol),
             ORKTextChoice(text: "Smell", value: "Smell" as NSCoding & NSCopying & NSObjectProtocol),
             ORKTextChoice(text: "Other", value: "Other" as NSCoding & NSCopying & NSObjectProtocol)
        ]
        
        let triggersAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .multipleChoice, textChoices: triggersTextChoices)
        let stepTriggers = ORKFormStep(identifier: "Other Triggers", title: "Select triggers, if any.", text: "")
        let formItem01TextTriggers = NSLocalizedString("", comment: "")
        let formItem01Triggers = ORKFormItem(identifier: "other_triggers", text: formItem01TextTriggers, answerFormat: ORKAnswerFormat.textAnswerFormat(withMaximumLength: 120))
        formItem01Triggers.placeholder = NSLocalizedString("Tap to specify other triggers", comment: "")
        let formItem02Triggers = ORKFormItem(identifier: "symptom_triggers", text: "", answerFormat:triggersAnswerFormat )
        
        stepTriggers.formItems = [formItem02Triggers,formItem01Triggers]
        steps += [stepTriggers]
        

        
        //PAIN RESOLUTION
        let symptomStatusQuestionStepTitle = "Compared to yesterday, are your symptoms…"
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
        steps += [scdPainDiffQuestionStep]
        
        let predicate = ORKResultPredicate.predicateForBooleanQuestionResult(
            with: ORKResultSelector(resultIdentifier: scdPainQuestionStep.identifier), expectedAnswer: false)
        let rule = ORKPredicateStepNavigationRule(
            resultPredicatesAndDestinationStepIdentifiers: [(predicate, ORKNullStepIdentifier)])
        
        let task = ORKNavigableOrderedTask(identifier: activityType.rawValue, steps: steps)
        task.setNavigationRule(rule, forTriggerStepIdentifier: scdPainQuestionStep.identifier)
        
        
        
        return task
    }
}

