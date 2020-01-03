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
    @IBOutlet weak var timer: NSTextField!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var statusImage: NSImageView!
    var activityStatus: ActivityStatus! // injected from AppDelegate
    var interval: Timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        launchAtLogin.intValue = LaunchAtLogin.isEnabled ? 1 : 0
        
        self.displayStatus()
        self.displayTimer()
        
        interval = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.displayStatus()
            self.displayTimer()
        })
        
    }
    
    override func viewDidDisappear() {
        interval.invalidate()
    }
    
    func displayTimer() {        
        if (activityStatus.activityTimer.isValid || activityStatus.breakTimer.isValid) {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .positional
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.zeroFormattingBehavior = .pad

            let now = Date()
            let targetDate = activityStatus.status == Status.Active ? activityStatus.activityTimer.fireDate : activityStatus.breakTimer.fireDate
            let formattedTimeLeft = formatter.string(from: now, to: targetDate)
            timer.stringValue = formattedTimeLeft ?? "00:00:00"
        } else {
            timer.stringValue = "00:00:00"
        }
    }
    
    func displayStatus() {
        statusLabel.stringValue = activityStatus.status.rawValue
        statusImage.image = mapStatusToImage(activityStatus.status)
    }
    
    func mapStatusToImage(_ status: Status) -> NSImage {
        switch status {
        case Status.Active:
            return NSImage(named: "NSStatusAvailable")!
        case Status.Break:
            return NSImage(named: "NSStatusUnavailable")!
        default:
            return NSImage(named: "NSStatusNone")!
        }
    }
    
    @IBAction func launchAtLoginPressed(_ sender: NSButton) {
        LaunchAtLogin.isEnabled = (sender.intValue as NSNumber).boolValue
    }
}

