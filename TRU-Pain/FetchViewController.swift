//
//  LocationViewController.swift
//  TRU-Pain
//
//  Created by jonas002 on 12/4/16.
//  Copyright © 2016 Jude Jonassaint. All rights reserved.
//  Copyright (c) 2016 Razeware LLC https://www.raywenderlich.com/143128/background-modes-tutorial-getting-started
//


import UIKit

class FetchViewController: UIViewController {
  
  @IBOutlet var updateLabel: UILabel!
  
  private var time: Date?
  private lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .long
    return formatter
  }()
  
  func fetch(_ completion: () -> Void) {
    time = Date()
    completion()
  }
  
  func updateUI() {
    guard updateLabel != nil  else {
      return
    }
    
    if let time = time {
      updateLabel.text = dateFormatter.string(from: time)
    } else {
      updateLabel.text = "Not yet updated"
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateUI()
  }
  
  @IBAction func didTapUpdate(_ sender: UIButton) {
    fetch { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.updateUI()
    }
  }
}
