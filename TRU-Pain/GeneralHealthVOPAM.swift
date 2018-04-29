//
//  GeneralHealthVOPAM.swift
//  TRU-Pain
//
//  Created by jonas002 on 9/29/17.
//  Copyright © 2017 scdi. All rights reserved.
//

import Foundation

import CareKit
import ResearchKit

/**
 Struct that conforms to the `Assessment` protocol to define a back pain
 assessment.
 */
struct GeneralHealthVOPAM: Assessment {
    // MARK: Activity
    
    let activityType: ActivityType = .generalHealthVOPAM
    
    func carePlanActivity() -> OCKCarePlanActivity {
        // Create a weekly schedule.
        let startDate = DateComponents(year: 2016, month: 01, day: 01)
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [1, 1, 1, 1, 1, 1, 1])
        
        // Get the localized strings to use for the assessment.
        let title = NSLocalizedString("General Health VOPAM" , comment: "")
        let summary = NSLocalizedString("", comment: "")
        
        let activity = OCKCarePlanActivity.assessment(withIdentifier: activityType.rawValue,
                                                      groupIdentifier: "Assessments",
                                                      title: title, text: summary,
                                                      tintColor: Colors.green.color,
                                                      resultResettable: true,
                                                      schedule: schedule,
                                                      userInfo: nil,
                                                      optional: false)
        
        return activity
    }
    
    // MARK: Assessment
    
    func task() -> ORKTask {
        var steps = [ORKStep]()
        
        let step = ORKFormStep(identifier:"GeneralHealthForm", title: "General Health", text: "")
        
        //HEALTH TODAY
        //let formItemGeneralHealthSection = ORKFormItem(sectionTitle: " ") ////////// SECTION
        let generalHealthScaleAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 10,
                                                                   minimumValue: 0,
                                                                   defaultValue: -1,
                                                                   step: 1,
                                                                   vertical: false,
                                                                   maximumValueDescription: NSLocalizedString("Best ever", comment: ""),
                                                                   minimumValueDescription: NSLocalizedString("Worst ever", comment: ""))
        let formItemGeneralHealth = ORKFormItem(identifier:"GeneralHealth", text: NSLocalizedString("On a scale from 0 to 10, how would you rate your health today?", comment: ""), answerFormat: generalHealthScaleAnswerFormat)
        //formItemGeneralHealth.placeholder = NSLocalizedString("Enter number", comment: "")
        
        
        //ANGER
        let formItemAngerSection = ORKFormItem(sectionTitle: " ") ////////// SECTION
        let AngerScaleAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 10,
                                                            minimumValue: 0,
                                                            defaultValue: -1,
                                                            step: 1,
                                                            vertical: false,
                                                            maximumValueDescription: NSLocalizedString("Worst ever", comment: ""),
                                                            minimumValueDescription: NSLocalizedString("None", comment: ""))
        let formItemAnger = ORKFormItem(identifier:"AngerItem", text: NSLocalizedString("On a scale from 0 to 10, how would you rate your anger today?", comment: ""), answerFormat: AngerScaleAnswerFormat)
        
        
        //SADNESS
        let formItemSadnessSection = ORKFormItem(sectionTitle: " ") ////////// SECTION
        let SadnessScaleAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 10,
                                                           minimumValue: 0,
                                                           defaultValue: -1,
                                                           step: 1,
                                                           vertical: false,
                                                           maximumValueDescription: NSLocalizedString("Worst ever", comment: ""),
                                                           minimumValueDescription: NSLocalizedString("None", comment: ""))
        let formItemSadness = ORKFormItem(identifier:"SadnessItem", text: NSLocalizedString("On a scale from 0 to 10, how would you rate your sadness today?", comment: ""), answerFormat: SadnessScaleAnswerFormat)
        
        
        
        //STRESS and Anxiety
        let formItemStressSection = ORKFormItem(sectionTitle: " ") ////////// SECTION
        let stressScaleAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 10,
                                                            minimumValue: 0,
                                                            defaultValue: -1,
                                                            step: 1,
                                                            vertical: false,
                                                            maximumValueDescription: NSLocalizedString("Worst ever", comment: ""),
                                                            minimumValueDescription: NSLocalizedString("None", comment: ""))
        let formItemStress = ORKFormItem(identifier:"StressItem", text: NSLocalizedString("On a scale from 0 to 10, how would you rate your stress and anxiety today?", comment: ""), answerFormat: stressScaleAnswerFormat)
        
        
        
        //NERVOUSNESS
        let formItemNervousnessSection = ORKFormItem(sectionTitle: " ") ////////// SECTION
        let NervousnessScaleAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 10,
                                                             minimumValue: 0,
                                                             defaultValue: -1,
                                                             step: 1,
                                                             vertical: false,
                                                             maximumValueDescription: NSLocalizedString("Worst ever", comment: ""),
                                                             minimumValueDescription: NSLocalizedString("None", comment: ""))
        let formItemNervousness = ORKFormItem(identifier:"NervousnessItem", text: NSLocalizedString("On a scale from 0 to 10, how would you rate your nervousness today?", comment: ""), answerFormat: NervousnessScaleAnswerFormat)
        
        
        //FATIGUED
        let formItemFatiguedSection = ORKFormItem(sectionTitle: " ") ////////// SECTION
        let FatiguedScaleAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 10,
                                                                 minimumValue: 0,
                                                                 defaultValue: -1,
                                                                 step: 1,
                                                                 vertical: false,
                                                                 maximumValueDescription: NSLocalizedString("Worst ever", comment: ""),
                                                                 minimumValueDescription: NSLocalizedString("Not at all", comment: ""))
        let formItemFatigued = ORKFormItem(identifier:"FatiguedItem", text: NSLocalizedString("On a scale from 0 to 10, how fatigued have you felt today?", comment: ""), answerFormat: FatiguedScaleAnswerFormat)
        
        
        
        
        //SLEEP QUALITY
        let formItemSleepQualitySection = ORKFormItem(sectionTitle: " ") ////////// SECTION
        let sleepQualityScaleAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 10,
                                                                  minimumValue: 0,
                                                                  defaultValue: -1,
                                                                  step: 1,
                                                                  vertical: false,
                                                                  maximumValueDescription: NSLocalizedString("Most satisfied", comment: ""),
                                                                  minimumValueDescription: NSLocalizedString("Not at all", comment: ""))
        let formItemSleepQuality = ORKFormItem(identifier:"SleepQualityItem", text: NSLocalizedString("How satisfied are you with the quality of sleep you got last night?", comment: ""), answerFormat: sleepQualityScaleAnswerFormat)
        //formItemSleepQuality.placeholder = NSLocalizedString("Enter number", comment: "")
          
        
        step.isOptional = false
        formItemGeneralHealth.isOptional = false
        formItemStress.isOptional = false
        //formItemSymptomsInterference.isOptional = false
        formItemSleepQuality.isOptional = false
        //formItemSymptomsInterference.isOptional = false
        
        //NSLocalizedString("Did your symptoms interfere with your activities today?", comment: "")
        step.formItems = [
            
            //formItemGeneralHealthSection,
            formItemGeneralHealth,
            
            formItemAngerSection,
            formItemAnger,
            
            formItemSadnessSection,
            formItemSadness,
            
            formItemStressSection, //and anxiety
            formItemStress,
            
            formItemNervousnessSection,
            formItemNervousness,
            
            formItemFatiguedSection,
            formItemFatigued,
            
            
            
//            formItemSleepSection,
//            formItemSleep,
            
            formItemSleepQualitySection,
            formItemSleepQuality,
            
            //formItemSymptomsInterferenceSection,
            //formItemSymptomsInterference
            
        ]
        steps += [step]
        
        
        // Create an ordered task with a single question.
        let task = ORKOrderedTask(identifier: activityType.rawValue, steps: steps)
        let taskDefault = UserDefaults()
        taskDefault.set("YES", forKey: "vasKey")
        
        return task
    }
}
