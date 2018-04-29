//
//  DocumentsDisplayViewController.swift
//  TRU-Pain
//
//  Created by jonas002 on 7/1/17.
//  Copyright © 2017 scdi. All rights reserved.
//

import Foundation
import UIKit
import CareKit


/**
 * A view controller which will display the OCKDocument in HTML format inside a web view, it also vends a `Done` and `Share` button.
 */
class DocumentsDisplayViewController: UIViewController {
    @IBOutlet weak var htmlDisplay: UIWebView!
    var documentObject: OCKDocument?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        htmlDisplay.loadHTMLString(documentObject!.htmlContent, baseURL: nil)
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func share(_ sender: UIBarButtonItem) {
        documentObject?.createPDFData(completion: { (data, _) in
            let activityVC = UIActivityViewController(activityItems: [data], applicationActivities: nil)
            DispatchQueue.main.async {
                self.present(activityVC, animated: true, completion: nil)
            }
        })
    }
}
