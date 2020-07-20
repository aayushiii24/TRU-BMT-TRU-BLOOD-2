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
  
  //TODO: Add VisualConsentStep
  
  //TODO: Add ConsentReviewStep
  
  return ORKOrderedTask(identifier: "ConsentTask", steps: steps)
}
