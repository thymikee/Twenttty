//
//  ViewController.swift
//  twenty
//
//  Created by Michał Pierzchała on 25/12/2019.
//  Copyright © 2019 Michał Pierzchała. All rights reserved.
//

import Cocoa
import LaunchAtLogin

class ViewController: NSViewController, NSTextFieldDelegate {
    @IBOutlet weak var timer: NSTextField!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var statusImage: NSImageView!
    @IBOutlet weak var preferences: NSButton!
    @IBOutlet weak var appVersionLabel: NSTextField!
    @IBOutlet weak var isMutedButton: NSButton!
    var activityStatus: ActivityStatus! // injected from AppDelegate
    var interval: Timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppName()
        displayStatus()
        displayTimer()
        displayMutedButton()
        
        interval = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.displayStatus()
            self.displayTimer()
        })
    }
    
    override func viewDidDisappear() {
        interval.invalidate()
    }
    
    @IBAction func onToggleMute(_ sender: Any) {
        activityStatus.breakNotification.isMuted = !activityStatus.breakNotification.isMuted
        displayMutedButton()
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
    
    func displayMutedButton() {
        if (activityStatus.breakNotification.isMuted) {
            isMutedButton.image = NSImage(named: "NSTouchBarAudioOutputMuteTemplate")
            isMutedButton.toolTip = "Unmute"
        } else {
            isMutedButton.image = NSImage(named: "NSTouchBarAudioOutputVolumeHighTemplate")
            isMutedButton.toolTip = "Mute"
        }
    }
    
    func setupAppName() {
        let name = Bundle.main.infoDictionary!["CFBundleName"] as! String
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        appVersionLabel.stringValue = name + " v" + version
    }
    
    func displayTimer() {
        let initialValue = "20:00"
        if (activityStatus.activityTimer.isValid || activityStatus.breakTimer.isValid) {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .positional
            formatter.allowedUnits = [.minute, .second]
            formatter.zeroFormattingBehavior = .pad

            let now = Date()
            let targetDate = activityStatus.status == Status.Active ? activityStatus.activityTimer.fireDate : activityStatus.breakTimer.fireDate
            let formattedTimeLeft = formatter.string(from: now, to: targetDate)
            timer.stringValue = formattedTimeLeft ?? initialValue
        } else {
            timer.stringValue = initialValue
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
