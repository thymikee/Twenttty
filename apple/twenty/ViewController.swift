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
    @IBOutlet weak var timer: NSTextField!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var statusImage: NSImageView!
    @IBOutlet weak var preferences: NSButton!
    @IBOutlet weak var appVersionLabel: NSTextField!
    @IBOutlet weak var warningCenter: NSImageView!
    var activityStatus: ActivityStatus! // injected from AppDelegate
    var interval: Timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppName()
        displayStatus()
        displayTimer()
        updateWarningCenter()
        
        interval = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.displayStatus()
            self.displayTimer()
        })
    }
    
    override func viewDidDisappear() {
        interval.invalidate()
    }
    
    @IBAction func onPreferencesPress(_ sender: NSButton) {
        let menu = NSMenu()
        let launchAtLoginItem = NSMenuItem(
            title: "Launch at Login",
            action: #selector(toggleLaunchAtLogin),
            keyEquivalent: ""
        )
        launchAtLoginItem.state = LaunchAtLogin.isEnabled ? NSControl.StateValue.on : NSControl.StateValue.off
        launchAtLoginItem.target = self

        let quitItem = NSMenuItem(
            title: "Quit",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self

        menu.addItem(launchAtLoginItem)
        menu.addItem(quitItem)
        menu.popUp(
            positioning: nil,
            at: NSPoint(x: 0, y: sender.frame.height),
            in: sender
        )
    }
    
    @objc func toggleLaunchAtLogin(_ sender: NSMenuItem) {
        LaunchAtLogin.isEnabled = !(sender.state as NSNumber).boolValue
    }
    
    @objc func quitApp() {
        exit(0)
    }
    
    func updateWarningCenter() {
        self.warningCenter.isHidden = self.activityStatus.breakNotification.isGranted
        self.warningCenter.toolTip = "Warnings:\nCan't notify you when to have a break :(. Please allow notifications for TwentyTwenty in System Preferences > Notifications."
    }
    
    func setupAppName() {
        let name = Bundle.main.infoDictionary!["CFBundleName"] as! String
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        appVersionLabel.stringValue = name + " v" + version
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
}
