import CareKit

/**
 Protocol that defines the properties and methods for sample activities.
 */
protocol Activity {
    var activityType: ActivityType { get }
    
    func carePlanActivity() -> OCKCarePlanActivity
}


/**
 Enumeration of strings used as identifiers for the `SampleActivity`s used in
 the app.
 */
enum ActivityType: String {
    
    //case hamstringStretch //VOPAM:
    
    
    case takeMedications
    case backPain
    
    case appetite
    case eatBreakfast
    case eatLunch
    case eatDinner
    case eatSnack
    case takeSleep
    
    case mood
    case bloodGlucose
    case weight
    
    case stools
    case stool
    case diarrhea
    case nausea
    case vomiting
    
    case rash
    case usualSelf
    //case generalHealth
    case spotting
    case scdPain
    case scdPainVOPAM
    case scdPainNotVOPAM
    case scdPainExperience
    case scdPainExperienceVOPAM
    case generalPainExperienceVOPAM
    case typesOfPainExperiencedVOPAM
    case painDifferentiation
    
    case abdominalCramp
    case urineCollection
    case menstruation
    case menstruationSCD
    case menstruationVOPAM
    case menstruating
    case fatigue
    case bodyLocation
    case stress
    case sickleCellPain
    
    case symptomFocus
    case temperature
    
    
    case outdoorWalk
    case meals
    case symptomForm
    
    //BMTJuly4
    //Health Card
    case OutdoorWalk
    case proteins
    case fruits
    case vegetables
    case dairy
    case grains
    //Assessment
    case symptomTracker
    case generalHealth
    case generalHealthVOPAM
    
    case stoolConsistency
    case surgicalPain
}
