//
//  ViewController.swift
//  twenty
//
//  Created by Michał Pierzchała on 25/12/2019.
//  Copyright © 2019 Michał Pierzchała. All rights reserved.
//

import Cocoa
import UserNotifications
import LaunchAtLogin

class ViewController: NSViewController, NSTextFieldDelegate {
    @IBOutlet weak var launchAtLogin: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        launchAtLogin.intValue = LaunchAtLogin.isEnabled ? 1 : 0
    }
    
    @IBAction func launchAtLoginPressed(_ sender: NSButton) {
        LaunchAtLogin.isEnabled = (sender.intValue as NSNumber).boolValue
    }
}

