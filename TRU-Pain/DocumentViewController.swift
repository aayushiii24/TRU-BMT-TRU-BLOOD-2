//
//  DocumentViewController.swift
//  ZombieCare
//
//  Created by Chris Baxter on 20/07/2016.
//  Copyright © 2016 Catalyst Mobile Ltd. All rights reserved.
//

import UIKit

class DocumentViewController: UIViewController {
    
    
    let webView : UIWebView
    let document : NSData

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(webView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    init(document:NSData) {
        
        self.document = document
        self.webView = UIWebView(frame: CGRectMake(0, 44, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - 44))

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Zombie Care Assesment"
        self.webView.loadData(self.document, MIMEType: "application/pdf", textEncodingName: "UTF-8", baseURL: NSURL())
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
