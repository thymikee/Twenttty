//
//  ViewController.swift
//  Twenttty
//
//  Created by Michał Pierzchała on 25/12/2019.
//  Copyright © 2019 Michał Pierzchała. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate {
    @IBOutlet weak var timer: NSTextField!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var statusImage: NSImageView!
    @IBOutlet weak var preferences: NSButton!
    @IBOutlet weak var appVersionLabel: NSTextField!
    @IBOutlet weak var isMutedButton: NSButton!
    var activityStatus: ActivityStatus! // injected
    var interval: Timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()

        setAppVersion()
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

    @IBAction func onToggleMute(_ sender: NSButton) {
        AppState.setIsMuted(!AppState.isMuted)
        displayMutedButton()
    }

    @IBAction func onPreferencesPress(_ sender: NSButton) {
        let menu = NSMenu()
        let launchAtLoginItem = NSMenuItem(
            title: NSLocalizedString("menu_launch_login", comment: ""),
            action: #selector(toggleLaunchAtLogin),
            keyEquivalent: ""
        )
        launchAtLoginItem.state = AppState.launchAtLogin ? NSControl.StateValue.on : NSControl.StateValue.off
        launchAtLoginItem.target = self

        let quitItem = NSMenuItem(
            title: NSLocalizedString("menu_quit", comment: ""),
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
        AppState.setLaunchAtLogin(!(sender.state as NSNumber).boolValue)
    }

    @objc func quitApp() {
        exit(0)
    }

    func displayMutedButton() {
        if (AppState.isMuted) {
            isMutedButton.image = NSImage(named: "NSTouchBarAudioOutputMuteTemplate")
            isMutedButton.toolTip = NSLocalizedString("tooltip_unmute", comment: "")
        } else {
            isMutedButton.image = NSImage(named: "NSTouchBarAudioOutputVolumeHighTemplate")
            isMutedButton.toolTip = NSLocalizedString("tooltip_mute", comment: "")
        }
        activityStatus.onActivityChange()
    }

    func setAppVersion() {
        appVersionLabel.stringValue = AppVersion.getAppName() + " v" + AppVersion.getVersion()
    }

    func displayTimer() {
        let initialValue = (String(Int(floor(activityStatus.activityTime / 60)))).padding(toLength: 2, withPad: "0", startingAt: 0) + ":00"
        let now = Date()
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad

        if (AppState.status == Status.Active) {
            timer.stringValue = formatter.string(from: now, to: activityStatus.activityTimer.fireDate) ?? initialValue
        } else if (AppState.status == Status.Break) {
            timer.stringValue = formatter.string(from: now, to: activityStatus.breakTimer.fireDate) ?? initialValue
        } else {
            timer.stringValue = initialValue
        }
    }

    func displayStatus() {
        let (image, label) = mapStatusToLabelData(AppState.status)
        statusLabel.stringValue = label
        statusImage.image = image
    }

    func mapStatusToLabelData(_ status: Status) -> (NSImage, String) {
        switch status {
        case Status.Active:
            return (NSImage(named: "NSStatusAvailable")!, NSLocalizedString("status_active", comment: ""))
        case Status.Break:
            return (NSImage(named: "NSStatusUnavailable")!, NSLocalizedString("status_break", comment: ""))
        default:
            return (NSImage(named: "NSStatusNone")!, NSLocalizedString("status_inactive", comment: ""))
        }
    }
}
