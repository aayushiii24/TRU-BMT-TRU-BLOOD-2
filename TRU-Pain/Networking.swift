//
//  Networking.swift
//  GIPain
//
//  Created by jonas002 on 9/9/18.
//  Copyright © 2018 scdi. All rights reserved.
//

import Foundation
//import Alamofire

enum UserError:Error{
    case NoDataAvailable
    case CanNotProcessData
}



//class Networking {
//    static let sharedInstance = Networking()
//    public var sessionManager: Alamofire.SessionManager // most of your web service clients will call through sessionManager
//    public var backgroundSessionManager: Alamofire.SessionManager // your web services you intend to keep running when the system backgrounds your app will use this
//    private init() {
//        self.sessionManager = Alamofire.SessionManager(configuration: URLSessionConfiguration.default)
//        self.backgroundSessionManager = Alamofire.SessionManager(configuration: URLSessionConfiguration.background(withIdentifier: "com.scdi.msband2app.backgroundtransfer"))
//    }
//}







extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
