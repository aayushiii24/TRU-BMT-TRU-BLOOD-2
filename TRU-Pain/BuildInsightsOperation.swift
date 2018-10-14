/*
 Copyright (c) 2017, Apple Inc. All rights reserved.
 
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
import Firebase
import CoreLocation


class BuildInsightsOperation: Operation {
    
    // MARK: Properties
    
    var outdoorWalkEvents: DailyEvents?
    var proteinsEvents: DailyEvents?
    var fruitsEvents: DailyEvents?
    var vegetablesEvents: DailyEvents?
    var dairyEvents: DailyEvents?
    var grainsEvents: DailyEvents?
    var generalHealthEvents: DailyEvents?
    var db:Firestore!
    
    fileprivate(set) var insights = [OCKInsightItem.emptyInsightsMessage()]
    
    // MARK: NSOperation
    
    override func main() {
        // Do nothing if the operation has been cancelled.
        guard !isCancelled else { return }
        
        // Create an array of insights.
        var newInsights = [OCKInsightItem]()
        
        if let insight = createGeneralHealthInsight() {
            newInsights.append(insight)
        }
        
        if let insight = createOutdoorWalkAdherenceInsight() {
            newInsights.append(insight)
        }
        
        if let insight = createProteinsAdherenceInsight() {
            newInsights.append(insight)
        }
        
        if let insight = createFruitsAdherenceInsight() {
            newInsights.append(insight)
        }
        
        if let insight = createVegetablesAdherenceInsight() {
            newInsights.append(insight)
        }
        
        if let insight = createDairyAdherenceInsight() {
            newInsights.append(insight)
        }
        
        if let insight = createGrainsAdherenceInsight() {
            newInsights.append(insight)
        }
        
        
        
        
        // Store any new insights thate were created.
        if !newInsights.isEmpty {
            insights = newInsights
        }
        
        
        
    }
    
    // MARK: Convenience
    func appMode(email:String) -> String {
        var mode:String = "Production"
        
        let itemsArray = ["AppleUser@icloud.com", "sicklecell@me.com", "trupain@icloud.com", "trupain000@icloud.com", "trupbmt000@icloud.com", "bmtckstudy000@icloud.com"]
        let filteredStrings = itemsArray.filter({(item: String) -> Bool in
            let stringMatch = item.lowercased().range(of: email)
            print("stringMatch \(String(describing: stringMatch))")
            return stringMatch != nil ? true : false
        })
        
        if filteredStrings.count == 0    {
            mode = "Production"
            print("app mode is Production")
        } else {
            mode = "Testing"
            print("app mode is Test")
        }
        
        
        
        return mode
    }
    
    func createOutdoorWalkAdherenceInsight() -> OCKInsightItem? {
        // Make sure there are events to parse.
        guard let outdoorWalkEvents = outdoorWalkEvents else { return nil }
        
        // Determine the start date for the previous week.
        let calendar = Calendar.current
        let now = Date()
        
        var components = DateComponents()
        components.day = -90
        let startDate = calendar.weekDatesForDate(calendar.date(byAdding: components as DateComponents, to: now)!).start
        
        var totalEventCount = 0
        var completedEventCount = 0
        
        for offset in (0...90).reversed() {
            components.day = offset
            let dayDate = calendar.date(byAdding: components as DateComponents, to: startDate)!
            let dayComponents = calendar.dateComponents([.year, .month, .day, .era], from: dayDate)
            let eventsForDay = outdoorWalkEvents[dayComponents]
            
            totalEventCount += eventsForDay.count
            
            for event in eventsForDay {
                if event.state == .completed {
                    completedEventCount += 1
                }
            }
        }
        
        guard totalEventCount > 0 else { return nil }
        
        // Calculate the percentage of completed events.
        let outdoorWalkAdherence = Float(completedEventCount) / Float(totalEventCount)
        
        // Create an `OCKMessageItem` describing medical adherence.
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        let formattedAdherence = percentageFormatter.string(from: NSNumber(value: outdoorWalkAdherence))!
        
        let insight = OCKMessageItem(title: "Exercise", text: formattedAdherence+" in past seven days", tintColor: Colors.blue.color, messageType: .tip)
        
        return insight
    }
    
    func createProteinsAdherenceInsight() -> OCKInsightItem? {
        // Make sure there are events to parse.
        guard let proteinsEvents = proteinsEvents else { return nil }
        
        // Determine the start date for the previous week.
        let calendar = Calendar.current
        let now = Date()
        
        var components = DateComponents()
        components.day = -90
        let startDate = calendar.weekDatesForDate(calendar.date(byAdding: components as DateComponents, to: now)!).start
        
        var totalEventCount = 0
        var completedEventCount = 0
        
        for offset in (0...90).reversed() {
            components.day = offset
            let dayDate = calendar.date(byAdding: components as DateComponents, to: startDate)!
            let dayComponents = calendar.dateComponents([.year, .month, .day, .era], from: dayDate)
            let eventsForDay = proteinsEvents[dayComponents]
            
            totalEventCount += eventsForDay.count
            
            for event in eventsForDay {
                if event.state == .completed {
                    completedEventCount += 1
                }
            }
        }
        
        guard totalEventCount > 0 else { return nil }
        
        // Calculate the percentage of completed events.
        let proteinsAdherence = Float(completedEventCount) / Float(totalEventCount)
        
        // Create an `OCKMessageItem` describing medical adherence.
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        let formattedAdherence = percentageFormatter.string(from: NSNumber(value: proteinsAdherence))!
        
        let insight = OCKMessageItem(title: "Proteins", text: formattedAdherence+" in past seven days", tintColor: Colors.redMeat.color, messageType: .tip)
        
        return insight
    }

    func createFruitsAdherenceInsight() -> OCKInsightItem? {
        // Make sure there are events to parse.
        guard let fruitsEvents = fruitsEvents else { return nil }
        
        // Determine the start date for the previous week.
        let calendar = Calendar.current
        let now = Date()
        
        var components = DateComponents()
        components.day = -90
        let startDate = calendar.weekDatesForDate(calendar.date(byAdding: components as DateComponents, to: now)!).start
        
        var totalEventCount = 0
        var completedEventCount = 0
        
        for offset in (0...90).reversed() {
            components.day = offset
            let dayDate = calendar.date(byAdding: components as DateComponents, to: startDate)!
            let dayComponents = calendar.dateComponents([.year, .month, .day, .era], from: dayDate)
            let eventsForDay = fruitsEvents[dayComponents]
            
            totalEventCount += eventsForDay.count
            
            for event in eventsForDay {
                if event.state == .completed {
                    completedEventCount += 1
                }
            }
        }
        
        guard totalEventCount > 0 else { return nil }
        
        // Calculate the percentage of completed events.
        let fruitsAdherence = Float(completedEventCount) / Float(totalEventCount)
        
        // Create an `OCKMessageItem` describing medical adherence.
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        let formattedAdherence = percentageFormatter.string(from: NSNumber(value: fruitsAdherence))!
        
        let insight = OCKMessageItem(title: "Fruits", text: formattedAdherence+" in past seven days", tintColor: Colors.yellow.color, messageType: .tip)
        
        return insight
    }
    
    func createVegetablesAdherenceInsight() -> OCKInsightItem? {
        // Make sure there are events to parse.
        guard let vegetablesEvents = vegetablesEvents else { return nil }
        
        // Determine the start date for the previous week.
        let calendar = Calendar.current
        let now = Date()
        
        var components = DateComponents()
        components.day = -90
        let startDate = calendar.weekDatesForDate(calendar.date(byAdding: components as DateComponents, to: now)!).start
        
        var totalEventCount = 0
        var completedEventCount = 0
        
        for offset in (0...90).reversed() {
            components.day = offset
            let dayDate = calendar.date(byAdding: components as DateComponents, to: startDate)!
            let dayComponents = calendar.dateComponents([.year, .month, .day, .era], from: dayDate)
            let eventsForDay = vegetablesEvents[dayComponents]
            
            totalEventCount += eventsForDay.count
            
            for event in eventsForDay {
                if event.state == .completed {
                    completedEventCount += 1
                }
            }
        }
        
        guard totalEventCount > 0 else { return nil }
        
        // Calculate the percentage of completed events.
        let vegetablesAdherence = Float(completedEventCount) / Float(totalEventCount)
        
        // Create an `OCKMessageItem` describing medical adherence.
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        let formattedAdherence = percentageFormatter.string(from: NSNumber(value: vegetablesAdherence))!
        
        let insight = OCKMessageItem(title: "Vegetables", text: formattedAdherence+" in past seven days", tintColor: Colors.green.color, messageType: .tip)
        
        return insight
    }
    
    func createDairyAdherenceInsight() -> OCKInsightItem? {
        // Make sure there are events to parse.
        guard let dairyEvents = dairyEvents else { return nil }
        
        // Determine the start date for the previous week.
        let calendar = Calendar.current
        let now = Date()
        
        var components = DateComponents()
        components.day = -90
        let startDate = calendar.weekDatesForDate(calendar.date(byAdding: components as DateComponents, to: now)!).start
        
        var totalEventCount = 0
        var completedEventCount = 0
        
        for offset in (0...90).reversed() {
            components.day = offset
            let dayDate = calendar.date(byAdding: components as DateComponents, to: startDate)!
            let dayComponents = calendar.dateComponents([.year, .month, .day, .era], from: dayDate)
            let eventsForDay = dairyEvents[dayComponents]
            
            totalEventCount += eventsForDay.count
            
            for event in eventsForDay {
                if event.state == .completed {
                    completedEventCount += 1
                }
            }
        }
        
        guard totalEventCount > 0 else { return nil }
        
        // Calculate the percentage of completed events.
        let dairyAdherence = Float(completedEventCount) / Float(totalEventCount)
        
        // Create an `OCKMessageItem` describing medical adherence.
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        let formattedAdherence = percentageFormatter.string(from: NSNumber(value: dairyAdherence))!
        
        let insight = OCKMessageItem(title: "Dairy", text: formattedAdherence+" in past seven days", tintColor: Colors.lightBlue.color, messageType: .tip)
        
        return insight
    }
    
    func createGrainsAdherenceInsight() -> OCKInsightItem? {
        // Make sure there are events to parse.
        guard let grainsEvents = grainsEvents else { return nil }
        
        // Determine the start date for the previous week.
        let calendar = Calendar.current
        let now = Date()
        
        var components = DateComponents()
        components.day = -90
        let startDate = calendar.weekDatesForDate(calendar.date(byAdding: components as DateComponents, to: now)!).start
        
        var totalEventCount = 0
        var completedEventCount = 0
        
        for offset in (0...90).reversed() {
            components.day = offset
            let dayDate = calendar.date(byAdding: components as DateComponents, to: startDate)!
            let dayComponents = calendar.dateComponents([.year, .month, .day, .era], from: dayDate)
            let eventsForDay = grainsEvents[dayComponents]
            
            totalEventCount += eventsForDay.count
            
            for event in eventsForDay {
                if event.state == .completed {
                    completedEventCount += 1
                }
            }
        }
        
        guard totalEventCount > 0 else { return nil }
        
        // Calculate the percentage of completed events.
        let grainsAdherence = Float(completedEventCount) / Float(totalEventCount)
        
        // Create an `OCKMessageItem` describing medical adherence.
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        let formattedAdherence = percentageFormatter.string(from: NSNumber(value: grainsAdherence))!
        print("grainsAdherence \(grainsAdherence)")
        
        let insight = OCKMessageItem(title: "Grains", text: formattedAdherence+" in past seven days", tintColor: Colors.wheat.color, messageType: .tip)
        
        return insight
    }
    
    func createGeneralHealthInsight() -> OCKInsightItem? {
        // Make sure there are events to parse.
        guard  let proteinsEvents = proteinsEvents, let fruitsEvents = fruitsEvents, let vegetablesEvents = vegetablesEvents, let dairyEvents = dairyEvents, let grainsEvents = grainsEvents, let generalHealthEvents = generalHealthEvents, let outdoorWalkEvents = outdoorWalkEvents else { return nil }
        
        // Determine the date to start health/proteins comparisons from.
        let calendar = Calendar.current
        var components = DateComponents()
        components.day = -90
        
        //Prep for data transfer
        
        
        let keychain = KeychainSwift()
        var participant:String?
        if keychain.get("username_TRU-BLOOD") != nil {
            participant = keychain.get("username_TRU-BLOOD")
        } else {
            participant = "unknown"
        }
        
        let startDate = calendar.date(byAdding: components as DateComponents, to: Date())!
        
        var archive:[[String]] = [[]]
        
        //var someArrayDateStrings:[String] = []
        
        
        
        // Create formatters for the data.
        let dayOfWeekFormatter = DateFormatter()
        dayOfWeekFormatter.dateFormat = "E"
        
        let shortDateFormatter = DateFormatter()
        shortDateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "Md", options: 0, locale: shortDateFormatter.locale)
        
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        
        /*
         Loop through 90 days, collecting proteins adherance and helath scores
         for each.
         */
        var generalHealthValues = [Int]()
        var generalHealthLabels = [String]()
        var outdoorWalkValues = [Float]()
        var outdoorWalkLabels = [String]()
        var proteinsValues = [Float]()
        var proteinsLabels = [String]()
        var fruitsValues = [Float]()
        var fruitsLabels = [String]()
        var vegetablesValues = [Float]()
        var vegetablesLabels = [String]()
        var dairyValues = [Float]()
        var dairyLabels = [String]()
        var grainsValues = [Float]()
        var grainsLabels = [String]()
        
        var axisTitles = [String]()
        var axisSubtitles = [String]()
        
        let dayOfWeekDateFormatter = DateFormatter()
        dayOfWeekDateFormatter.dateFormat = "EEEE"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let monthOfYearDateFormatter = DateFormatter()
        monthOfYearDateFormatter.dateFormat = "MMM"
        
        let yearOfEventDateFormatter = DateFormatter()
        yearOfEventDateFormatter.dateFormat = "yyyy"
        
        let utcDateFormatter = DateFormatter()
        utcDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        
        for offset in (0...90).reversed() {
            
            let settings = FirestoreSettings()
            Firestore.firestore().settings = settings
            settings.isPersistenceEnabled = true
            
            // Determine the day to components.
            var someArray:[String] = []//Data transfer
            
            
            components.day = offset
            
            let dayDate = calendar.date(byAdding: components as DateComponents, to: startDate)!
            let dayComponents = calendar.dateComponents([.year, .month, .day, .era], from: dayDate)
            let userCalendar = Calendar.current
            
            
            
            let someDateTime = userCalendar.date(from: (dayComponents as DateComponents?)!)
            let dateString = formatter.string(from: someDateTime!)
            let dayOfWeek = dayOfWeekDateFormatter.string(from: someDateTime!)
            let monthOfYear = monthOfYearDateFormatter.string(from: someDateTime!)
            let yearOfEvent = yearOfEventDateFormatter.string(from: someDateTime!)
            
            someArray.append(dateString)
            
            var careCardDiary = [String: String]() //for firebase
            
            
            
            
            // Store the GENERAL HEALTH result for the current day.
            if let result = generalHealthEvents[dayComponents].first?.result, let score = Int(result.valueString) , score > 0 {
                generalHealthValues.append(score)
                generalHealthLabels.append(result.valueString)
                someArray.append(result.valueString)
            }
            else {
                generalHealthValues.append(0)
                generalHealthLabels.append(NSLocalizedString("N/A", comment: ""))
                someArray.append("-999")
//                someArrayDateStrings.append(dateString)
            }
            
            
            // Store the BRISK WALK adherance value for the current day.
            let outdoorWalkEventsForDay = outdoorWalkEvents[dayComponents]
            if let adherence = percentageEventsCompleted(outdoorWalkEventsForDay) , adherence > 0.0 {
                // Scale the adherance to the same 0-10 scale as generalHealth values.
                let scaledAdeherence = adherence * 10.0
                
                outdoorWalkValues.append(scaledAdeherence)
                outdoorWalkLabels.append(percentageFormatter.string(from: NSNumber(value: adherence))!)
                someArray.append(percentageFormatter.string(from: NSNumber(value: adherence))!)
                //someArrayDateStrings.append(dateString)
                
                
                careCardDiary["exercise"] = percentageFormatter.string(from: NSNumber(value: adherence))!
                
            }
            else {
                outdoorWalkValues.append(0.0)
                outdoorWalkLabels.append(NSLocalizedString("N/A", comment: ""))
                someArray.append("-999")
                careCardDiary["exercise"] = "0"
                //someArrayDateStrings.append(dateString)
            }
            
            // Store the PROTEINS adherance value for the current day.
            let proteinsEventsForDay = proteinsEvents[dayComponents]
            if let adherence = percentageEventsCompleted(proteinsEventsForDay) , adherence > 0.0 {
                // Scale the adherance to the same 0-10 scale as generalHealth values.
                let scaledAdeherence = adherence * 10.0
                
                proteinsValues.append(scaledAdeherence)
                proteinsLabels.append(percentageFormatter.string(from: NSNumber(value: adherence))!)
                someArray.append(percentageFormatter.string(from: NSNumber(value: adherence))!)
                //someArrayDateStrings.append(dateString)
                
                careCardDiary["proteins"] = percentageFormatter.string(from: NSNumber(value: adherence))!
                
            }
            else {
                proteinsValues.append(0.0)
                proteinsLabels.append(NSLocalizedString("N/A", comment: ""))
                someArray.append("-999")
                //someArrayDateStrings.append(dateString)
                careCardDiary["proteins"] = "0"
            }
            
            // Store the FRUITS adherance value for the current day.
            let fruitsEventsForDay = fruitsEvents[dayComponents]
            if let adherence = percentageEventsCompleted(fruitsEventsForDay) , adherence > 0.0 {
                // Scale the adherance to the same 0-10 scale as generalHealth values.
                let scaledAdeherence = adherence * 10.0
                
                fruitsValues.append(scaledAdeherence)
                fruitsLabels.append(percentageFormatter.string(from: NSNumber(value: adherence))!)
                someArray.append(percentageFormatter.string(from: NSNumber(value: adherence))!)
                //someArrayDateStrings.append(dateString)
                
                careCardDiary["fruits"] = percentageFormatter.string(from: NSNumber(value: adherence))!
               
                
            }
            else {
                fruitsValues.append(0.0)
                fruitsLabels.append(NSLocalizedString("N/A", comment: ""))
                someArray.append("-999")
                //someArrayDateStrings.append(dateString)
                careCardDiary["fruits"] = "0"
            }
            
            
            
            // Store the VEGETABLES adherance value for the current day.
            let vegetablesEventsForDay = vegetablesEvents[dayComponents]
            if let adherence = percentageEventsCompleted(vegetablesEventsForDay) , adherence > 0.0 {
                // Scale the adherance to the same 0-10 scale as generalHealth values.
                let scaledAdeherence = adherence * 10.0
                
                vegetablesValues.append(scaledAdeherence)
                vegetablesLabels.append(percentageFormatter.string(from: NSNumber(value: adherence))!)
                someArray.append(percentageFormatter.string(from: NSNumber(value: adherence))!)
                //someArrayDateStrings.append(dateString)
                careCardDiary["vegetables"] = percentageFormatter.string(from: NSNumber(value: adherence))!
                
            }
            else {
                vegetablesValues.append(0.0)
                vegetablesLabels.append(NSLocalizedString("N/A", comment: ""))
                someArray.append("-999")
                //someArrayDateStrings.append(dateString)
                careCardDiary["vegetables"] = "0"
            }
            
            // Store the DAIRY adherance value for the current day.
            let dairyEventsForDay = dairyEvents[dayComponents]
            if let adherence = percentageEventsCompleted(dairyEventsForDay) , adherence > 0.0 {
                // Scale the adherance to the same 0-10 scale as generalHealth values.
                let scaledAdeherence = adherence * 10.0
                
                dairyValues.append(scaledAdeherence)
                dairyLabels.append(percentageFormatter.string(from: NSNumber(value: adherence))!)
                someArray.append(percentageFormatter.string(from: NSNumber(value: adherence))!)
                //someArrayDateStrings.append(dateString)
                careCardDiary["dairy"] = percentageFormatter.string(from: NSNumber(value: adherence))!
                
            }
            else {
                dairyValues.append(0.0)
                dairyLabels.append(NSLocalizedString("N/A", comment: ""))
                someArray.append("-999")
               // someArrayDateStrings.append(dateString)
                careCardDiary["dairy"] = "0"
            }
            
            
            // Store the DAIRY adherance value for the current day.
            let grainsEventsForDay = grainsEvents[dayComponents]
            if let adherence = percentageEventsCompleted(grainsEventsForDay) , adherence > 0.0 {
                // Scale the adherance to the same 0-10 scale as generalHealth values.
                let scaledAdeherence = adherence * 10.0
                
                grainsValues.append(scaledAdeherence)
                grainsLabels.append(percentageFormatter.string(from: NSNumber(value: adherence))!)
                someArray.append(percentageFormatter.string(from: NSNumber(value: adherence))!)
                //someArrayDateStrings.append(dateString)
                careCardDiary["grains"] = percentageFormatter.string(from: NSNumber(value: adherence))!
                
                
            }
            else {
                grainsValues.append(0.0)
                grainsLabels.append(NSLocalizedString("N/A", comment: ""))
                someArray.append("-999")
                //someArrayDateStrings.append(dateString)
                careCardDiary["grains"] = "0"
            }
            
            
           

            
            
            
            ///////////////////////////
            axisTitles.append(dayOfWeekFormatter.string(from: dayDate))
            axisSubtitles.append(shortDateFormatter.string(from: dayDate))
            
            print("dictionaryOfDailyEvents[dateString] = someDict \(someArray)" )
            
            let date = NSDate()
            let localDateString = utcDateFormatter.string(from: date as Date)
            someArray.append(localDateString)
            someArray.insert(participant!, at: 0)
            
            archive.append(someArray)
            
//            let settings = FirestoreSettings()
//            Firestore.firestore().settings = settings
//            settings.isPersistenceEnabled = true
            
            // [START FIREBASE setup]
            db = Firestore.firestore()
            
            let options = QueryListenOptions()
            options.includeQueryMetadataChanges(true)

            db.collection("users").whereField("dayOfWeekOfEvent", isEqualTo: "Sunday")
                .addSnapshotListener(options: options) { querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error retreiving snapshot: \(error!)")
                        return
                    }

                    for diff in snapshot.documentChanges {
                        if diff.type == .added {
                            print("New care card diary: \(diff.document.data())")
                        }
                    }

                    let source = snapshot.metadata.isFromCache ? "local cache" : "server"
                    print("Metadata: Data fetched from \(source)")
            }
            
            let handle = Auth.auth().addStateDidChangeListener { (auth, user) in
                if let user = user {
                    let uid = user.uid
                    let email = user.email
                    //let photoURL = user.photoURL
                    careCardDiary["userID"] = uid
                    careCardDiary["userEmail"] = email
                    careCardDiary["author_id"] = uid
                    careCardDiary["dataOfType"] = "careCardDiary"
                    careCardDiary["dayOfWeekOfEvent"] = dayOfWeek
                    careCardDiary["monthOfYearOfEvent"] = monthOfYear
                    careCardDiary["yearOfEvent"] = yearOfEvent
                    careCardDiary["dateOfEvent"] = dateString
                    careCardDiary["appMode"] = self.appMode(email: email!)
                    
                    
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        print("version of app \(version)")
                        careCardDiary["appVersion"] = version
                    }
                    if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                        print("version of app \(build)")
                        careCardDiary["appBuild"] = build
                    }
                    let idForFirestore = "CareCard." + dateString + "." + uid
                    
                    var ref: DocumentReference? = nil
                    self.db.collection("cares").document(idForFirestore).setData(careCardDiary) { err in
                        
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document successfully written!")
                            }
                    }
                }
            }
        }
        
        
        
        let headerArray = ["participant","dayString","Health","Proteins","Fruits","Vegetables","Dairy","Grains","Walk","fileUploadedOn"]
        
        archive.remove(at: 0)
        archive.insert(headerArray, at: 0)
        print(archive)
//        for  x in 0..<archive.count {
//            var line = ""
//            for  y in 0..<archive[x].count {
//                line += String(archive[x][y])
//                line += " "
//                print("My line starts for each y line \(line)")
//            }
//            print("My line starts here \(line)")
//        }
        
        //upload array of arrays as a CSV file each a seection is made from the health card screen
        let uploadSymptomFocus = UploadApi()
        uploadSymptomFocus.writeAndUploadCSVToSharefile(forSymptomFocus: archive, "chartsData.csv")
        print("archive.append(someArray ) \(archive)")
        
        // Create a `OCKBarSeries` for each set of data.
//        let generalHealthBarSeries = OCKBarSeries(title: "Health", values: generalHealthValues as [NSNumber], valueLabels: generalHealthLabels, tintColor: Colors.blue.color)
        
      
        let outdoorWalkBarSeries = OCKBarSeries(title: "Walk", values: outdoorWalkValues as [NSNumber], valueLabels: outdoorWalkLabels, tintColor: Colors.blue.color)
        let proteinsBarSeries = OCKBarSeries(title: "Proteins", values: proteinsValues as [NSNumber], valueLabels: proteinsLabels, tintColor: Colors.redMeat.color)
        let fruitsBarSeries = OCKBarSeries(title: "Fruits", values: fruitsValues as [NSNumber], valueLabels: fruitsLabels, tintColor: Colors.yellow.color)
        let vegetablesBarSeries = OCKBarSeries(title: "Vegetables", values: vegetablesValues as [NSNumber], valueLabels: vegetablesLabels, tintColor: Colors.green.color)
        let dairyBarSeries = OCKBarSeries(title: "Dairy", values: dairyValues as [NSNumber], valueLabels: dairyLabels, tintColor: Colors.lightBlue.color)
        let grainsBarSeries = OCKBarSeries(title: "Grains", values: grainsValues as [NSNumber], valueLabels: grainsLabels, tintColor: Colors.orange.color)
        
        
        /*
         Add the series to a chart, specifing the scale to use for the chart
         rather than having CareKit scale the bars to fit.
         */
        let chart = OCKBarChart(title: "Nutrition / Walks",
                                text: "",
                                tintColor: Colors.blue.color,
                                axisTitles: axisTitles,
                                axisSubtitles: axisSubtitles,
                                dataSeries: [outdoorWalkBarSeries,proteinsBarSeries,fruitsBarSeries, vegetablesBarSeries, dairyBarSeries, grainsBarSeries])
        //return chart
        return nil //this remove the bar charts from the insight view.
    }
    
    /**
     For a given array of `OCKCarePlanEvent`s, returns the percentage that are
     marked as completed.
     */
    fileprivate func percentageEventsCompleted(_ events: [OCKCarePlanEvent]) -> Float? {
        guard !events.isEmpty else { return nil }
        
        let completedCount = events.filter({ event in
            event.state == .completed
        }).count
        
        return Float(completedCount) / Float(events.count)
    }
}

/**
 An extension to `SequenceType` whose elements are `OCKCarePlanEvent`s. The
 extension adds a method to return the first element that matches the day
 specified by the supplied `NSDateComponents`.
 */

extension Sequence where Iterator.Element: OCKCarePlanEvent {
    func eventForDay(_ dayComponents: NSDateComponents) -> Iterator.Element? {
        for event in self where
            event.date.year == dayComponents.year &&
                event.date.month == dayComponents.month &&
                event.date.day == dayComponents.day {
                    return event
        }
        return nil
    }
}

