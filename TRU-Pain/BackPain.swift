/*
 Copyright (c) 2016, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import CareKit
import ResearchKit

/**
 Struct that conforms to the `Assessment` protocol to define a back pain
 assessment.
 */
struct BackPain: Assessment {
    // MARK: Activity
    
    let activityType: ActivityType = .backPain
    
    func carePlanActivity() -> OCKCarePlanActivity {
        // Create a weekly schedule.
        let startDate = DateComponents(year: 2017, month: 01, day: 01)
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [1, 1, 1, 1, 1, 1, 1])
        
        // Get the localized strings to use for the assessment.
        let title = NSLocalizedString("General Health" , comment: "")
        let summary = NSLocalizedString("Daily", comment: "")
        
        let activity = OCKCarePlanActivity.assessment(
            withIdentifier: activityType.rawValue,
            groupIdentifier: nil,
            title: title,
            text: summary,
            tintColor: Colors.green.color,
            resultResettable: true,
schedule: schedule, userInfo: nil, thresholds: nil, optional: false)
        
        return activity
    }
    
    // MARK: Assessment
    
    func task() -> ORKTask {
        // Get the localized strings to use for the task.
//        let question = NSLocalizedString("On a scale of 0-10, how is your pain today?", comment: "")
//      
//    
//        
//        // Create a question and answer format.
//        let answerFormat = ORKScaleAnswerFormat(
//            maximumValue: 10,
//            minimumValue: 0,
//            defaultValue: -1,
//            step: 1,
//            vertical: false,
//            maximumValueDescription: "Worst pain",
//            minimumValueDescription: "No pain"
//        )
//
//        
//        
//        
//        let questionStep = ORKQuestionStep(identifier: activityType.rawValue, title: question, answer: answerFormat)
//        questionStep.isOptional = false
        
        
        let questionGeneralHealth = NSLocalizedString("On a scale from 0 to 10, how would you rate your health today?", comment: "")
        let maximumValueDescriptionGeneralHealth = NSLocalizedString("Best ever", comment: "")
        let minimumValueDescriptionGeneralHealth = NSLocalizedString("Worst ever", comment: "")
        
        // Create a question and answer format.
        let answerFormatGeneralHealth = ORKScaleAnswerFormat(
            maximumValue: 10,
            minimumValue: 0,
            defaultValue: -1,
            step: 1,
            vertical: false,
            maximumValueDescription: maximumValueDescriptionGeneralHealth,
            minimumValueDescription: minimumValueDescriptionGeneralHealth
        )
        
        let questionStepGeneralHealth = ORKQuestionStep(identifier: "generalHealth", title: questionGeneralHealth, answer: answerFormatGeneralHealth)
        questionStepGeneralHealth.isOptional = false
        

        
        // Get the localized strings to use for the MOOD task.
        let questionMood = NSLocalizedString("On a scale from 0 to 10, how would you rate your mood today?", comment: "")
        let maximumValueDescriptionMood = NSLocalizedString("Good", comment: "")
        let minimumValueDescriptionMood = NSLocalizedString("Bad", comment: "")
        
        
        
        // Create a question and answer format for MOOD.
        let answerFormatMood = ORKScaleAnswerFormat(
            maximumValue: 10,
            minimumValue: 0,
            defaultValue: -1,
            step: 1,
            vertical: false,
            maximumValueDescription: maximumValueDescriptionMood,
            minimumValueDescription: minimumValueDescriptionMood
        )
        
        let questionStepMood = ORKQuestionStep(identifier: "mood", title: questionMood, answer: answerFormatMood)
        questionStepMood.isOptional = false
        
        
        let questionStress = NSLocalizedString("On a scale from 0 to 10, how would you rate your stress today?", comment: "")
        let maximumValueDescriptionStress = NSLocalizedString("High", comment: "")
        let minimumValueDescriptionStress = NSLocalizedString("Low", comment: "")
        
        
        // Create a question and answer format form STRESS.
        let answerFormatStress = ORKScaleAnswerFormat(
            maximumValue: 10,
            minimumValue: 0,
            defaultValue: -1,
            step: 1,
            vertical: false,
            maximumValueDescription: maximumValueDescriptionStress,
            minimumValueDescription: minimumValueDescriptionStress
        )
        
        
        let questionStepStress = ORKQuestionStep(identifier: "stress", title: questionStress, answer: answerFormatStress)
        questionStepStress.isOptional = false
        
        
        // Get the localized strings to use for the task.
        let questionFatigue = NSLocalizedString("On a scale from 0 to 10, how fatigue have you felt today?", comment: "")
        let maximumValueDescriptionFatigue = NSLocalizedString("A lot", comment: "")
        let minimumValueDescriptionFatigue = NSLocalizedString("Not at all", comment: "")
        
        // Create a question and answer format.
        let answerFormatFatigue = ORKScaleAnswerFormat(
            maximumValue: 10,
            minimumValue: 0,
            defaultValue: -1,
            step: 1,
            vertical: false,
            maximumValueDescription: maximumValueDescriptionFatigue,
            minimumValueDescription: minimumValueDescriptionFatigue
        )
        
        let questionStepFatigue = ORKQuestionStep(identifier: "fatigue", title: questionFatigue, answer: answerFormatFatigue)
        questionStepFatigue.isOptional = false
        
        
        
        // Sleep quality
        let questionSleepQuality = NSLocalizedString("How satisfied are you with the quality of sleep you got last night?", comment: "")
        let maximumValueDescriptionSleepQuality  = NSLocalizedString("Quite satisfied", comment: "")
        let minimumValueDescriptionSleepQuality  = NSLocalizedString("Not at all", comment: "")
        
        let answerFormatSleepQuality  = ORKScaleAnswerFormat(
            maximumValue: 10,
            minimumValue: 0,
            defaultValue: -1,
            step: 1,
            vertical: false,
            maximumValueDescription: maximumValueDescriptionSleepQuality ,
            minimumValueDescription: minimumValueDescriptionSleepQuality
        )
        
        
        let questionStepSleepQuality = ORKQuestionStep(identifier: "sleepQuality", title: questionSleepQuality , answer: answerFormatSleepQuality )
        questionStepSleepQuality.isOptional = false
        
        //Symtom Interference
        let questionStepTitleSymptomInterference = NSLocalizedString("Did your symptoms interfere with your activities today?", comment: "")
        let textChoicesSymptomInterference = [
            ORKTextChoice(text: "No", value: 0 as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Yes", value: 1 as NSCoding & NSCopying & NSObjectProtocol)
        ]
        let answerFormatSymptomInterference: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: textChoicesSymptomInterference)
         let questionStepSymptomInterference = ORKQuestionStep(identifier: "symptomInterference", title: questionStepTitleSymptomInterference, answer: answerFormatSymptomInterference)
        questionStepSymptomInterference.isOptional = false
        
        // Create an ordered task with a single question.
        let task = ORKOrderedTask(identifier: activityType.rawValue, steps: [questionStepGeneralHealth, questionStepMood, questionStepStress, questionStepFatigue, questionStepSleepQuality])
        let taskDefault = UserDefaults()
        taskDefault.set("YES", forKey: "vasKey")
        return task
    }
}
