//
//  ConsentTask.swift
//  TRU-BMT
//
//  Created by Aayushi Patel on 7/18/20.
//  Copyright © 2020 scdi. All rights reserved.
//

import Foundation
import ResearchKit

public var ConsentTask: ORKOrderedTask {
  
    var steps = [ORKStep]()
  
    var consentDocument = ConsentDocument
    let visualConsentStep = ORKVisualConsentStep(identifier: "VisualConsentStep", document: consentDocument)
    steps += [visualConsentStep]

  
    let signature = consentDocument.signatures!.first!

    let reviewConsentStep = ORKConsentReviewStep(identifier: "ConsentReviewStep", signature: signature, in: consentDocument)

    reviewConsentStep.text = "Review Consent!"
    reviewConsentStep.reasonForConsent = "Consent to join study"

    steps += [reviewConsentStep]
    return ORKOrderedTask(identifier: "ConsentTask", steps: steps)
    
}
