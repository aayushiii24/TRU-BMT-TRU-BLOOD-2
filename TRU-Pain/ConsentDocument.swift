//
//  ConsentDocument.swift
//  TRU-BMT
//
//  Created by Aayushi Patel on 7/18/20.
//  Copyright © 2020 scdi. All rights reserved.
//

import Foundation
import ResearchKit

public var ConsentDocument: ORKConsentDocument {
  
  let consentDocument = ORKConsentDocument()
  consentDocument.title = NSLocalizedString("Study Consent Form", comment: "")

    let section1 = ORKConsentSection(type: .overview)
  section1.summary = NSLocalizedString("Section 1 Summary", comment: "")
  section1.content = NSLocalizedString("Section 1 Content…", comment: "")

    let section2 = ORKConsentSection(type: .dataGathering)
  section2.summary = NSLocalizedString("Section 2 Summary", comment: "")
  section2.content = NSLocalizedString("Section 2 Content…", comment: "")

    let section3 = ORKConsentSection(type: .privacy)
  section3.summary = NSLocalizedString("Section 3 Summary", comment: "")
  section3.content = NSLocalizedString("Section 3 Content…", comment: "")

  consentDocument.sections = [section1, section2, section3]
  
  let consentSectionTypes: [ORKConsentSectionType] = [
    .overview,
    .dataGathering,
    .privacy,
    .dataUse,
    .timeCommitment,
    .studySurvey,
    .studyTasks,
    .withdrawing
  ]
    var consentSections: [ORKConsentSection] = consentSectionTypes.map { contentSectionType in
      let consentSection = ORKConsentSection(type: contentSectionType)
      consentSection.summary = "If you wish to complete this study..."
      consentSection.content = "In this study you will be asked five (wait, no, three!) questions. You will also have your voice recorded for ten seconds."
      return consentSection
    }

    consentDocument.sections = consentSections

  consentDocument.addSignature(ORKConsentSignature(forPersonWithTitle: nil, dateFormatString: nil, identifier: "ConsentDocumentParticipantSignature"))

  return consentDocument
}
