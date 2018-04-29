//
//  GeneralPainExperienceVOPAM.swift
//  TRU-Pain
//
//  Created by jonas002 on 9/30/17.
//  Copyright © 2017 scdi. All rights reserved.
//

//General

import CareKit
import ResearchKit


/**
 Struct that conforms to the `Assessment` protocol to define a back pain
 assessment.
 */
struct GeneralPainExperienceVOPAM: Assessment {
    // MARK: Activity
    
    let activityType: ActivityType = .generalPainExperienceVOPAM
    
    func carePlanActivity() -> OCKCarePlanActivity {
        // Create a weekly schedule.
        let startDate = DateComponents(year: 2016, month: 01, day: 01)
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [1, 1, 1, 1, 1, 1, 1])
        
        // Get the localized strings to use for the assessment.
        let title = NSLocalizedString("Non Sickle Cell Pain VOPAM", comment: "")
        //        let summary = NSLocalizedString("Lower Back", comment: "")
        
        let activity = OCKCarePlanActivity.assessment(withIdentifier: activityType.rawValue, groupIdentifier: nil, title: title, text: "", tintColor: Colors.blue.color, resultResettable: true, schedule: schedule, userInfo: nil, optional: false)
        
        return activity
    }
    
    // MARK: Assessment
    
    func task() -> ORKTask {
        
        var steps = [ORKStep]()
        
        //a.Are you experiencing sickle cell pain?
        let generalPainQuestionStepTitle = "Are you experiencing non-sickle cell pain?"
        let generalPainAnswerFormat = ORKBooleanAnswerFormat()
        let generalPainQuestionStep = ORKQuestionStep(identifier: "generalPainIdentifier", title: generalPainQuestionStepTitle, answer: generalPainAnswerFormat)
        generalPainQuestionStep.isOptional = false
        steps += [generalPainQuestionStep]
        
        
        //i. RATE YOUR PAIN
        let avgPainQuestion = NSLocalizedString("Please rate your average non-sickle cell pain over the past 24 hours.", comment: "")
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
        let mostPainQuestion = NSLocalizedString("Please rate your most recent non-sickle cell pain over the past 24 hours.", comment: "")
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
        let bodyLocationQuestionStep = ORKQuestionStep(identifier: "scdPain_affected_body_locations", title: "Where on your body is this non-sickle cell pain?", answer: bodyLocationAnswerFormat)
        bodyLocationQuestionStep.isOptional = false
        steps += [bodyLocationQuestionStep]
        
        
        
        
        //PREVIOUS
        let generalPainHxQuestionStepTitle = "Have you experienced this non-sickle cell pain before?"
        let generalPainHxAnswerFormat = ORKBooleanAnswerFormat()
        let generalPainHxQuestionStep = ORKQuestionStep(identifier: "generalPainHxIdentifier", title: generalPainHxQuestionStepTitle, answer: generalPainHxAnswerFormat)
        generalPainHxQuestionStep.isOptional = false
        steps += [generalPainHxQuestionStep]
        
        
        
        
        
        
        //PAIN DESCRIPTION
        let generalPainDescriptionQuestionStepTitle = "Compare to your usual sickle cell pain, how is this one?"
        let generalPainDescriptionTextChoices = [
            ORKTextChoice(text: "Aching", value: "Aching" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Burning", value: "Burning" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Stabbing", value: "Stabbing" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Cramping", value: "Cramping" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Tingling", value: "Tingling" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Throbbing", value: "Throbbing" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Pounding", value: "Pounding" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Electrifying", value: "Electrifying" as NSCoding & NSCopying & NSObjectProtocol),
            ]
        
        let generalPainDescriptionAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .multipleChoice, textChoices: generalPainDescriptionTextChoices)
        let generalPainDescriptionQuestionStep = ORKQuestionStep(identifier: "generalPainDescription", title: generalPainDescriptionQuestionStepTitle, answer: generalPainDescriptionAnswerFormat)
        generalPainDescriptionQuestionStep.isOptional = false
        steps += [generalPainDescriptionQuestionStep]
        
        
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
        
        
        
        //PAIN FREQUENCY
        let generalPainFrequencyQuestionStepTitle = "How often do you experience this pain?"
        let generalPainFrequencyTextChoices = [
            ORKTextChoice(text: "Multiple times a day", value: "Multiple times a day" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Once a day", value: "Once a day" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Once a week", value: "Once a week" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Once a month", value: "Once a month" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "This pain is new", value: "This pain is new" as NSCoding & NSCopying & NSObjectProtocol)
        ]
        
        let generalPainFrequencyAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: generalPainFrequencyTextChoices)
        let generalPainFrequencyQuestionStep = ORKQuestionStep(identifier: "generalPainFrequency", title: generalPainFrequencyQuestionStepTitle, answer: generalPainFrequencyAnswerFormat)
        generalPainFrequencyQuestionStep.isOptional = false
        steps += [generalPainFrequencyQuestionStep]
        
        
        //PAIN DIFFERENCE
        //“Can you tell the difference between your sickle cell pain and your menstrual pain?”
        let scdPainDiffQuestionStepTitle = "Over the past 24 hours ..."
        let scdPainDiffTextChoices = [
            ORKTextChoice(text: "I had sickle pain", value: "SCDPain" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "I had menstrual pain", value: "MenstrualPain" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "I had other pain not from sickle cell or menstruation", value: "GeneralPain" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "I had pain that I could not classify", value: "Unclassified" as NSCoding & NSCopying & NSObjectProtocol)
        ]
        
        let scdPainDiffAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .multipleChoice, textChoices: scdPainDiffTextChoices)
        let scdPainDiffQuestionStep = ORKQuestionStep(identifier: "differentiatesPain", title: scdPainDiffQuestionStepTitle, answer: scdPainDiffAnswerFormat)
        scdPainDiffQuestionStep.isOptional = false
        steps += [scdPainDiffQuestionStep]
        
        
        let predicate = ORKResultPredicate.predicateForBooleanQuestionResult(
            with: ORKResultSelector(resultIdentifier: generalPainQuestionStep.identifier), expectedAnswer: false)
        let rule = ORKPredicateStepNavigationRule(
            resultPredicatesAndDestinationStepIdentifiers: [(predicate, ORKNullStepIdentifier)])
        
        let task = ORKNavigableOrderedTask(identifier: activityType.rawValue, steps: steps)
        task.setNavigationRule(rule, forTriggerStepIdentifier: generalPainQuestionStep.identifier)
        
        
        
        return task
    }
}


