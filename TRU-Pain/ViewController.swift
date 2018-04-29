//
//  ViewController.swift
//  TRU-BLOOD
//
//  Created by jonas002 on 12/23/16.
//  Copyright © 2016 scdi. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import UserNotifications
import Firebase
import FirebaseInstanceID

//import GoogleSignIn


class ViewController: UIViewController  //GIDSignInUIDelegate
{
    var db: Firestore!
    var studyName: String?
    var study: String?
    
    var managedContext: NSManagedObjectContext!
    typealias JSONStandard = Dictionary<String, AnyObject>
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    //@IBOutlet weak var signinButton: GIDSignInButton!
    @IBOutlet weak var registerButton: UIButton!
    
    //Firebase// create reference to database and data storage
//    var userStorage: FIRStorageReference!
//    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let standardDefaults = UserDefaults.standard
        if standardDefaults.object(forKey: "ORKSampleFirstRun") as! String == "ORKSampleFirstRun" {
          self.loginButton.isHidden = true
        }
        
        let keychain = KeychainSwift()
        if keychain.get("username_TRU-BLOOD") != nil  && keychain.get("password_TRU-BLOOD") != nil {
            self.usernameTextField.text = keychain.get("username_TRU-BLOOD")
            self.passwordTextField.text = keychain.get("password_TRU-BLOOD")
            
            self.db = Firestore.firestore()
            //self.makeRefs(database: self.db)
            
            let settings = FirestoreSettings()
            Firestore.firestore().settings = settings
            settings.isPersistenceEnabled = true
            
//            var ref: DocumentReference? = nil
//            ref = self.db.collection("users").addDocument(data: [
//                "first": "Ada",
//                "last": "Lovelace",
//                "born": 1815
//            ]) { err in
//                if let err = err {
//                    print("Error adding document: \(err)")
//                } else {
//                    print("Document added with ID: \(ref!.documentID)")
//                }
//            }
            
        }
        
        
        
//        Auth.auth().createUser(withEmail: "sicklecell@me.com", password: "Welcome8_") { (user, error) in
//            // ...
//        }
        
//        GIDSignIn.sharedInstance().uiDelegate = self as! GIDSignInUIDelegate
//        GIDSignIn.sharedInstance().signIn()
        

        
        
        // [START get_iid_token]
        let token = InstanceID.instanceID().token()
        print(token ?? "TOKEN -999")
        // [END get_iid_token]
        
        Messaging.messaging().subscribe(toTopic: "/topics/news")
        print("Subscribed to news topic")
        
        
    }
    
   // MARK: - Google Sign in
//    @IBAction func loginWithGoogle(_ sender: Any) {
//        GIDSignIn.sharedInstance().uiDelegate = self as! GIDSignInUIDelegate
//        GIDSignIn.sharedInstance().signIn()
//
//
//
//    }
    
//
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
//        // ...
//
//        if let error = error {
//            // ...
//            print(error)
//            return
//        }
//
//        guard let authentication = user.authentication else { return }
//        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
//                                                          accessToken: authentication.accessToken)
//
//        Auth.auth().signIn(with: credential) { (user, error) in
//            // ...
//            print("signed in successfully")
//            if let error = error {
//                // ...
//                print(error)
//                return
//            }
//        }
//
//    }
//
    
    func makeRefs(database db: Firestore) -> (CollectionReference, DocumentReference) {
        var collectionRef = db.collection("users")
        
        var documentRef: DocumentReference
        documentRef = collectionRef.document("my-doc")
        // or
       // documentRef = db.document("my-collection/my-doc")
        
        // deeper collection (my-collection/my-doc/some/deep/collection)
        collectionRef = documentRef.collection("some/deep/collection")
        
        // parent doc (my-collection/my-doc/some/deep)
        documentRef = collectionRef.parent!
        
        // print paths.
        print("Collection: \(collectionRef.path), document: \(documentRef.path)")
        
        return (collectionRef, documentRef)
    }
    
    
    func registrationFailed()  {
        let alert = UIAlertController(title: "Registration failed!",
                                      message: "Check Internet connection and credentitals, and try again",
                                      preferredStyle: .alert)
        
        
        alert.addTextField { (textField) in
            textField.keyboardType = .default
            //textField.placeholder = "STUDY"
            textField.text = "BMT"
        }
        
        alert.addTextField { (textField) in
            textField.keyboardType = .emailAddress
            textField.placeholder = "email"
            textField.text = "AppleUser@icloud.com"
        }
        
        alert.addTextField { (textField) in
            textField.keyboardType = .default
            textField.isSecureTextEntry = true
            textField.placeholder = "password"
            textField.text = "Welcome11"
        }
        
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            
            [unowned self] action in
            
            guard let studyTextField = alert.textFields?.first,
                let userTextField = alert.textFields?[1],
                let passwordTextField = alert.textFields?.last
                
                else {
                    return
            }
            self.study = studyTextField.text
            self.update(user: userTextField.text, password: passwordTextField.text, study: self.study)
            SAMKeychain.setAccessibilityType(kSecAttrAccessibleWhenUnlocked)
            SAMKeychain.setPassword(self.study!, forService: "comSicklesoftTRUBMT", account: "Study")
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        present(alert, animated: true)

    }
    
    @IBAction func registerAction(_ sender: Any) {
        
        let alert = UIAlertController(title: "Register",
                                      message: "Must be connected to the Internet",
                                      preferredStyle: .alert)
        
        
        alert.addTextField { (textField) in
            textField.keyboardType = .default
            //textField.placeholder = "STUDY"
            textField.text = "BMT"
        }
        
        alert.addTextField { (textField) in
            textField.keyboardType = .emailAddress
            textField.placeholder = "email"
            textField.text = "AppleUser@icloud.com"
        }
        
        alert.addTextField { (textField) in
            textField.keyboardType = .default
            textField.isSecureTextEntry = true
            textField.placeholder = "password"
            textField.text = "Welcome11"
        }
        
        //trupain@icloud.com 7YmKnV2oa5UCc3wFJN40MCozXwx2
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            
            [unowned self] action in
            
            guard let studyTextField = alert.textFields?.first,
                let userTextField = alert.textFields?[1],
                let passwordTextField = alert.textFields?.last
                
                else {
                    return
            }
            self.study = studyTextField.text
            self.update(user: userTextField.text, password: passwordTextField.text, study: self.study)
            SAMKeychain.setAccessibilityType(kSecAttrAccessibleWhenUnlocked)
            SAMKeychain.setPassword(self.study!, forService: "comSicklesoftTRUBMT", account: "Study")
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        present(alert, animated: true)
    }

    
    func update(user: String?, password: String?, study: String?) {
        let standardDefaults = UserDefaults.standard
        let studyName = study?.uppercased()
        let credential = URLCredential(user: user!, password: password!, persistence: .none)
        //Alamofire.request("https://scdi.sharefile-webdav.com:443/Dev/SMARTa/\(user!)/\(studyName!)/profile.json")
            //change generic profile data to Onboard/BMT.json or Onboard/VOPAM.json or Onboard/SCD.json or Onboard/SCDF.json
            //change address "https://scdi.sharefile-webdav.com:443/Dev/SMARTa/\(user!)/\(studyName!)/profile.json"
            //to https://scdi.sharefile-webdav.com:443/\(studyName!)/profile.json"
            //Ensure that user has download access to the profile
            //If register button is used esure that the database for CareKit is cleared to be reprogrammed
            //Should a dump upload of current data occur in the background prior to wiping out CareKit
        Alamofire.request("https://scdi.sharefile-webdav.com:443/Onboard/\(studyName!).json")
            .authenticate(usingCredential: credential)
            .responseJSON { response in
                print("debugPrint(response.result)")
                debugPrint(response.result)
                print("debugPrint(response.data)")
                debugPrint(response.data ?? "no data")
            
                guard String(describing: response.result).lowercased().range(of:"failure") == nil else {
                    print("registration failed")
                    self.registrationFailed()
                    return
                }
                    print("Yeah, response not nil")
                    
                    self.loginButton.isHidden = false
                    self.usernameTextField.text = user
                    self.passwordTextField.text = password
                    let keychain = KeychainSwift()
                    keychain.delete("username_TRU-BLOOD")
                    keychain.delete("password_TRU-BLOOD")
                    
                    keychain.set(user!, forKey: "username_TRU-BLOOD", withAccess: .accessibleWhenUnlocked)
                    keychain.set(password!, forKey: "password_TRU-BLOOD", withAccess: .accessibleWhenUnlocked)
                    if let dict = response.result.value as? JSONStandard {
                        for (key,value) in dict {
                            print("\(key) = \(value)")
                            keychain.set(value as! String, forKey: key, withAccess: .accessibleAfterFirstUnlockThisDeviceOnly)
                            SAMKeychain.setPassword(value as! String, forService: "comSicklesoftTRUBMT", account:key)
                       
                            if key == "Institution" {
                                SAMKeychain.setAccessibilityType(kSecAttrAccessibleWhenUnlocked)
                                SAMKeychain.setPassword(value as! String, forService: "comSicklesoftTRUBMT", account: "Institution")
                                standardDefaults.set(value, forKey: "Institution")
                            }
                            if key == "Study" {
                                standardDefaults.set(value, forKey: "Study")
                            }
                        }
                    }
                
                keychain.set(user!, forKey: "Email")
                    SAMKeychain.setPassword(user!, forService: "comSicklesoftTRUBMT", account: "username")
                    SAMKeychain.setPassword(password!, forService: "comSicklesoftTRUBMT", account: user!)
                    standardDefaults.setValue("Done", forKey: "ORKSampleFirstRun")
                
                Auth.auth().createUser(withEmail: user!, password: password!) { (user, error) in
                    // ...
                    print(" user and error \(String(describing: user)) and \(String(describing: error))")
                }
        }
    }
    
    //FIREBASE//
    func firebaseUserLogin(user:String, password:String)  {
     
    }

    
    
    func scheduleFirstReminderNotification() {
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        let content = UNMutableNotificationContent()
        content.title = "Hello"
        content.body = "Keep track of your health measures."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "ReminderInfo"]
        content.sound = UNNotificationSound.default()
        
        
        //let study = self.study?.lowercased()
        //let imageName = "crc"+study!
        let urlpath     = Bundle.main.path(forResource: "crcvopamvanderbilt", ofType: "png")
        let url         = NSURL.fileURL(withPath: urlpath!)
        if let studyCoordinatorImage = try? UNNotificationAttachment(identifier:
            "studyCoordinatorImage", url: url, options: nil) {
            content.attachments = [studyCoordinatorImage]
        }
        
        //let keychain = KeychainSwift()
        
        /*
 var firstReminderHourString = "10"
        var firstReminderMinuteString = "00"
        
        
        //remove non numeric characters if any
        firstReminderHourString = firstReminderHourString.trimmingCharacters(in: NSCharacterSet(charactersIn: "0123456789.").inverted)
        firstReminderMinuteString = firstReminderMinuteString.trimmingCharacters(in: NSCharacterSet(charactersIn: "0123456789.").inverted)
        
        if firstReminderHourString.characters.first == "0" && firstReminderHourString.characters.count > 1  && firstReminderHourString.characters.last != "0" {
            firstReminderHourString.remove(at: firstReminderHourString.startIndex)
        }
        
        if firstReminderMinuteString.characters.first == "0" && firstReminderMinuteString.characters.count > 1 && firstReminderHourString.characters.last != "0" {
            firstReminderMinuteString.remove(at: firstReminderMinuteString.startIndex)
        }
        
        if firstReminderHourString.characters.first == "0" && firstReminderHourString.characters.count > 1  && firstReminderHourString.characters.last == "0" {
            firstReminderHourString = "0"
        }
        
        if firstReminderMinuteString.characters.first == "0" && firstReminderMinuteString.characters.count > 1 && firstReminderHourString.characters.last == "0" {
            firstReminderMinuteString = "0"
        }

        print("reminders time minute \(firstReminderHourString, firstReminderMinuteString)")
        print(Int(firstReminderHourString) ?? -99)
        print(Int(firstReminderMinuteString) ?? -99)
*/
        
        var dateComponents = DateComponents()
        dateComponents.hour = 22 //Int(firstReminderHourString)
        dateComponents.minute = 10 //Int(firstReminderMinuteString)
        
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
        
    }
    
    func scheduleSecondReminderNotification() {
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()   
        let content = UNMutableNotificationContent()
        content.title = "Hello"
        content.body = "You are keeping track of your health measures?"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "ReminderInfo"]
        content.sound = UNNotificationSound.default()
        
//        let study = self.study?.lowercased()
//        let imageName = "crc2"+study!
        let urlpath     = Bundle.main.path(forResource: "crc2VopamVanderbilt", ofType: "png")
        let url         = NSURL.fileURL(withPath: urlpath!)
        if let studyCoordinatorImage = try? UNNotificationAttachment(identifier:
            "studyCoordinatorImage", url: url, options: nil) {
            content.attachments = [studyCoordinatorImage]
        }
        
        
        var dateComponents = DateComponents()
        dateComponents.hour = 22 //Int(firstReminderHourString)
        dateComponents.minute = 15 //Int(firstReminderMinuteString)
        
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    ///Use this in case we need to delete all records for an entity
    func deleteALLRecordsForEntity(entity: String) -> () {
        
        let context = NSManagedObjectContext.default()
        
        
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context?.execute(batchDeleteRequest)
            print("Deleted all")
            
        } catch {
            print("Error deleleting all")// Error Handling
        }
    }
    
    @IBAction func loginAction(_ sender: Any) {
        scheduleFirstReminderNotification()
        scheduleSecondReminderNotification()
        
        
        let keychain = KeychainSwift()
        if keychain.get("username_TRU-BLOOD") != nil {
            
            if self.usernameTextField.text == keychain.get("username_TRU-BLOOD") &&  self.passwordTextField.text == keychain.get("password_TRU-BLOOD") {
                Auth.auth().signIn(withEmail: self.usernameTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                    // ...
                    print("user?.uid \(user?.uid)")
                    self.db = Firestore.firestore()
                    self.makeRefs(database: self.db)
                    
                    let settings = FirestoreSettings()
                    Firestore.firestore().settings = settings
                    settings.isPersistenceEnabled = true
                    
//                    var ref: DocumentReference? = nil
//                    ref = self.db.collection("users").addDocument(data: [
//                        "first": "Ada",
//                        "last": "Lovelace",
//                        "born": 1815
//                    ]) { err in
//                        if let err = err {
//                            print("Error adding document: \(err)")
//                        } else {
//                            print("Document added with ID: \(ref!.documentID)")
//                        }
//                    }
                    
                }
                
                

                performSegue(withIdentifier: "toRootViewController", sender: nil)
                
            } else {
                self.wrongUsernameOrPasswordAlert()
            }
            
            //self.passwordTextField.text = keychain.get("password_TRU-BLOOD")//TEMP: remove
            
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)  {
        print("print the number: 0")
        
        
        
    }
    
    func wrongUsernameOrPasswordAlert () {
        let alert = UIAlertController(title: "Wrong user name or password",
                                      message: "The username and/or password entered are not recognized.",
                                      preferredStyle: .alert)
        
            
        let cancelAction = UIAlertAction(title: "OK", style: .default)
        
        
        alert.addAction(cancelAction)
        present(alert, animated: true)

    }
    
    

}






// print(UserDefaults.standard.dictionaryRepresentation())
// print(UserDefaults.standard.dictionaryRepresentation().keys)
// self.scheduleFirstReminderNotification()
// self.deleteALLRecordsForEntity(entity: "DGeoData")
// self.deleteALLRecordsForEntity(entity: "DSymptomFocus")
