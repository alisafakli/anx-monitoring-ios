//
//  ViewController.swift
//  ANXMonitoringIOS
//
//  Created by anx-asafakli on 05/13/2019.
//  Copyright (c) 2019 anx-asafakli. All rights reserved.
//

import UIKit
import ANXMonitoringIOS

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            if let path = Bundle.main.path(forResource: "Frameworks", ofType: "plist"), let nsDictionary = NSDictionary(contentsOfFile: path) {
                let _ = Monitoring(nsDictionary, enableLog: true)
                
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

