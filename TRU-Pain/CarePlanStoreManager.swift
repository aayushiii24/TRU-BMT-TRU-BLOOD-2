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

class CarePlanStoreManager: NSObject {
    // MARK: Static Properties
    
    static var sharedCarePlanStoreManager = CarePlanStoreManager()
    
    // MARK: Properties
    
    weak var delegate: CarePlanStoreManagerDelegate?
    
    let store: OCKCarePlanStore
    
    var insights: [OCKInsightItem] {
        return insightsBuilder.insights
    }
    
    fileprivate let insightsBuilder: InsightsBuilder

    // MARK: Initialization
    
    fileprivate override init() {
        // Determine the file URL for the store.
        let searchPaths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        let applicationSupportPath = searchPaths[0]
        let persistenceDirectoryURL = URL(fileURLWithPath: applicationSupportPath)
        
        if !FileManager.default.fileExists(atPath: persistenceDirectoryURL.absoluteString, isDirectory: nil) {
            try! FileManager.default.createDirectory(at: persistenceDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Create the store.
        store = OCKCarePlanStore(persistenceDirectoryURL: persistenceDirectoryURL)
        
        /*
            Create an `InsightsBuilder` to build insights based on the data in
            the store.
        */
        insightsBuilder = InsightsBuilder(carePlanStore: store)
        
        super.init()
//********************************START -- DO NOT USE UNLESS DEBUGGING****************//
       // self._clearStore()
//********************************END -- DO NOT USE UNLESS DEBUGGING****************//
        
        
        
        self.store.activities(with: .intervention) { (success, activities, errorOrNil) in
            guard success else {
                // perform proper error handling here
                fatalError(errorOrNil!.localizedDescription)
            }
            print("ActivitiesDescription \(activities)")
            // now do something with the activities.
            for x in activities {
                print(x.identifier)
                print(x.schedule)

                guard let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) else {
                    fatalError("This should never fail.")
                }
                
                // Read the events for the ibuprofen activity for today
                let today = calendar.components([.day, .month, .year], from: NSDate() as Date)
                self.store.events(for: x, date: today) { (events, errorOrNil) in
                    
                    if let error = errorOrNil {
                        // Perform proper error handling here
                        fatalError(error.localizedDescription)
                    }
                    // do something with the ibuprofen events.
                    print("title")
                    print(x.title)
                    print(events.first?.state.rawValue ?? "-199")
                    print(events.first?.result?.valueString ?? "-299")
                    //print(events.first?.result as Int ?? "-399")
                }
            }
        }
        
        
        
        
        
        // Register this object as the store's delegate to be notified of changes.
        store.delegate = self
        
        // Start to build the initial array of insights.
        updateInsights()
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    
    func _clearStore() {
        print("*** CLEANING STORE DEBUG ONLY ****")
        
        let deleteGroup = DispatchGroup()
        let store = self.store
        
        deleteGroup.enter()
        store.activities { (success, activities, errorOrNil) in
            
            guard success else {
                // Perform proper error handling here...
                fatalError(errorOrNil!.localizedDescription)
            }
            
            for activity in activities {
                
                deleteGroup.enter()
                store.remove(activity) { (success, error) -> Void in
                    
                    print("Removing \(activity)")
                    guard success else {
                        fatalError("*** An error occurred: \(error!.localizedDescription)")
                    }
                    print("Removed: \(activity)")
                    deleteGroup.leave()
                }
            }
            
            deleteGroup.leave()
        }
        delayWithSeconds(1) {
            //Do something
            deleteGroup.wait()
        }
        // Wait until all the asynchronous calls are done.
        //deleteGroup.wait(timeout: dispatch_time_t(DispatchTime.distantFuture))
        //DispatchTime.distantFuture
    }
    
    func updateInsights() {
        insightsBuilder.updateInsights { [weak self] completed, newInsights in
            // If new insights have been created, notifiy the delegate.
            guard let storeManager = self, let newInsights = newInsights , completed else { return }
            storeManager.delegate?.carePlanStoreManager(storeManager, didUpdateInsights: newInsights)
        }
    }
    
    func generateDocument(comment: String?) -> OCKDocument? {
        
        var elements: [OCKDocumentElement] = []
        let subtitleElement = OCKDocumentElementSubtitle(subtitle: "Assessment for TRU-Pain")
        elements.append(subtitleElement)
        
        let zombieImage = UIImage(named: "crcbmtduke")
        let imageElement = OCKDocumentElementImage(image: zombieImage!)
        elements.append(imageElement)
        
        if self.insights.count > 0 {
            print("we have some insigths")
            let introElement = OCKDocumentElementParagraph(content: "Below are some insights with respect self assessments.")
            elements.append(introElement)
            
            let insightHeaders : [String]? = ["Messages"]
            var insightRows : [[String]]? = [[]]
            
            for insight in self.insights {
                
                if insight.isKind(of: OCKMessageItem.self) {
                   print("we have a message")
                    insightRows![0].append(insight.text!)
                }
                print(insight)
            }
            
            let tableElement = OCKDocumentElementTable(headers: insightHeaders, rows: insightRows)
            elements.append(tableElement)
            
            for insight in self.insights {
                print("we have insights here")
                if insight.isKind(of: OCKChart.self) {
                    print("we have a chart")
                    let chartElement = OCKDocumentElementChart(chart: insight as! OCKChart)
                    elements.append(chartElement)
                    break;
                }
            }
        }
        
        let keychain = KeychainSwift()
        var usernameString = "Patient"
        if keychain.get("username_TRU-BLOOD") != nil {
            usernameString = keychain.get("username_TRU-BLOOD")!
            
        }
        
        let subtitleCommentsElement = OCKDocumentElementSubtitle(subtitle: usernameString)
        elements.append(subtitleCommentsElement)
        
        if let theComment = comment {
            let commnetsElement = OCKDocumentElementParagraph(content: theComment)
            elements.append(commnetsElement)
        }
        else {
            let commnetsElement = OCKDocumentElementParagraph(content: "No Comments")
            elements.append(commnetsElement)
        }
        
        let subtitleSummaryElement = OCKDocumentElementSubtitle(subtitle: "Summary")
        elements.append(subtitleSummaryElement)
        
        let summaryparagraphElement = OCKDocumentElementParagraph(content: "*Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
        elements.append(summaryparagraphElement)
        
        
        let document = OCKDocument(title: "TRU-Pain", elements: elements)
        document.pageHeader = "TRU-Pain, Version 2.0, - \(NSDate())"
        
        return document
    }
    
    
    

}



extension CarePlanStoreManager: OCKCarePlanStoreDelegate {
    func carePlanStoreActivityListDidChange(_ store: OCKCarePlanStore) {
        updateInsights()
    }
    
    func carePlanStore(_ store: OCKCarePlanStore, didReceiveUpdateOf event: OCKCarePlanEvent) {
        updateInsights()
    }
}



protocol CarePlanStoreManagerDelegate: class {
    
    func carePlanStoreManager(_ manager: CarePlanStoreManager, didUpdateInsights insights: [OCKInsightItem])
    
    
}








