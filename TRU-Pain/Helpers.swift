//
//  Helpers.swift
//  TRU-Pain
//
//  Created by jonas002 on 8/29/17.
//  Copyright © 2017 scdi. All rights reserved.
//

import Foundation
import DefaultsKit

class Helpers {
    
    func normalize(_ values: [Double?]) -> [NSNumber] {
        let valuesWithDefaults = values.map({ (value) -> Double in
            guard let value = value else { return 0.0 }
            return value
        })
        
        guard let maxValue = valuesWithDefaults.max() , maxValue > 0.0 else {
            return valuesWithDefaults.map({ NSNumber(value:$0) })
        }
        
        return valuesWithDefaults.map({NSNumber(value: $0 / maxValue)})
    }
    
    func currentDatePickerDate() -> Date {
        
        let defaults = Defaults.shared
        
        //should make a function that returns the date for the pickerInitialDate
        let dateKey = Key<String>("CurrentDateForDatePicker")
        let x = defaults.get(for: dateKey)
        print("here is the date I want \(String(describing: x))")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "MMM d, yyyy, HH:mm"
        
        //need to add current time to x
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let y = x!+", "+String(describing: hour)+":"+String(describing:minutes)
        let pickerInitialDate = dateFormatter.date(from: y)
        print("pickerInitialDate \(y) \(String(describing: pickerInitialDate))")
        return pickerInitialDate!
    }
    
}
