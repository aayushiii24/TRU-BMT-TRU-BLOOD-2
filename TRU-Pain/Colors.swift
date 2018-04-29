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

import UIKit

enum Colors {
    
    case beige, red, redMeat, crimsonRed, careKitRed, green, blue, lightBlue, moderateCyan, pink, purple, sandyBrown, tan, yellow, wheat, orangeRed, gold, orange, darkOrange
    
    var color: UIColor {
        switch self {
            
        case .beige:
            return UIColor(red: 0xF5 / 255.0, green: 0xF5 / 255.0, blue: 0xDC / 255.0, alpha: 1.0)
            
        case .sandyBrown:
            return UIColor(red: 0xF4 / 255.0, green: 0xA4 / 255.0, blue: 0x60 / 255.0, alpha: 1.0)
            
        case .tan:
            return UIColor(red: 0xD2 / 255.0, green: 0xB4 / 255.0, blue: 0x8C / 255.0, alpha: 1.0)
            
        case .wheat:
            return UIColor(red: 0xF5 / 255.0, green: 0xDE / 255.0, blue: 0xB3 / 255.0, alpha: 1.0)
            
        case .red:
            return UIColor(red: 0xEF / 255.0, green: 0x44 / 255.0, blue: 0x5B / 255.0, alpha: 1.0)
            
        case .redMeat:
            return UIColor(red: 0x91 / 255.0, green: 0x07 / 255.0, blue: 0x07 / 255.0, alpha: 1.0)
            
        case .careKitRed:
            return UIColor(red: 0xdb / 255.0, green: 0x3f / 255.0, blue: 0x3f / 255.0, alpha: 1.0)
            //ce3535
            //db3f3f
        //likeable dark blue #005a8f
        case .crimsonRed:
            return UIColor(red: 0xce / 255.0, green: 0x35 / 255.0, blue: 0x35 / 255.0, alpha: 1.0)
            
        case .green:
            return UIColor(red: 0x8D / 255.0, green: 0xC6 / 255.0, blue: 0x3F / 255.0, alpha: 1.0)
            
        case .blue:
            return UIColor(red: 0x3E / 255.0, green: 0xA1 / 255.0, blue: 0xEE / 255.0, alpha: 1.0)
            
        case .lightBlue:
            return UIColor(red: 0x9C / 255.0, green: 0xCF / 255.0, blue: 0xF8 / 255.0, alpha: 1.0)
            
        case .moderateCyan:
            return hexStringToUIColor(hex: "#35a8ce")
            
        //#35a8ce
        case .pink:
            return UIColor(red: 0xF2 / 255.0, green: 0x6D / 255.0, blue: 0x7D / 255.0, alpha: 1.0)
            
        case .purple:
            return UIColor(red: 0x9B / 255.0, green: 0x59 / 255.0, blue: 0xB6 / 255.0, alpha: 1.0)
            
        case .yellow:
            return UIColor(red: 0xF1 / 255.0, green: 0xDF / 255.0, blue: 0x15 / 255.0, alpha: 1.0)
            
        //ORANGE
        case .orangeRed:
            return UIColor(red: 0xFF / 255.0, green: 0x45 / 255.0, blue: 0x00 / 255.0, alpha: 1.0)
            
        case .gold:
            return UIColor(red: 0xFF / 255.0, green: 0xD7 / 255.0, blue: 0x00 / 255.0, alpha: 1.0)
            
        case .orange:
            return UIColor(red: 0xFF / 255.0, green: 0xA5 / 255.0, blue: 0x00 / 255.0, alpha: 1.0)
            
        case .darkOrange:
            return UIColor(red: 0xFF / 255.0, green: 0x8C / 255.0, blue: 0x0 / 255.0, alpha: 1.0)
        }
    }
}
func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.characters.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
