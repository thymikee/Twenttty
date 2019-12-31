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
        
        interval = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .positional
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.zeroFormattingBehavior = .pad

            let now = Date()
            let targetDate = self.activityStatus.status == Status.Active ? self.activityStatus.activityTimer.fireDate : self.activityStatus.breakTimer.fireDate
            let formattedTimeLeft = formatter.string(from: now, to: targetDate)
            
            self.statusLabel.stringValue = self.activityStatus.status.rawValue
            self.statusImage.image = self.mapStatusToImage(self.activityStatus.status)
            
            if (self.activityStatus.activityTimer.isValid || self.activityStatus.breakTimer.isValid) {
                self.timer.stringValue = formattedTimeLeft ?? "00:00:00"
            } else {
                self.timer.stringValue = "00:00:00"
            }
        })
        
    }
    
    override func viewDidDisappear() {
        interval.invalidate()
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

