//
//  WindowViewController.swift
//  Twenttty
//
//  Created by Michał Pierzchała on 19/06/2020.
//  Copyright © 2020 Michał Pierzchała. All rights reserved.
//

import Cocoa

class AboutViewController: NSViewController {
    @IBOutlet weak var appVersionLabel: NSTextField!
    @IBOutlet weak var appNameLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAppVersion()
    }
    
    func setAppVersion() {
        appVersionLabel.stringValue = NSLocalizedString("version", comment: "") + " " + AppVersion.getVersion()
    }
    
    func setAppName() {
        appNameLabel.stringValue = AppVersion.getAppName()
    }
}
