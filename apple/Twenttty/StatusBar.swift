//
//  StatusBar.swift
//  Twenttty
//
//  Created by Michał Pierzchała on 24/05/2020.
//  Copyright © 2020 Michał Pierzchała. All rights reserved.
//

import Cocoa

class StatusBar: NSObject, ActivityStatusDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let statusBarIcon = NSImage(named: "12")
    var activityStatus = ActivityStatus()

    override init() {
        super.init()
        
        activityStatus.delegate = self
        initStatusBarIcon()
    }

    func initStatusBarIcon() {
        statusBarIcon?.isTemplate = true
        statusItem.button?.image = statusBarIcon
        statusItem.button?.target = self
    }

    func onActivityChange(_ sender: ActivityStatus) {
        updateStatusItemImage()
    }

    func updateStatusItemImage() {
        if (AppState.status == Status.Active) {
            let timeLeft = abs(Date().timeIntervalSince(activityStatus.activityTimer.fireDate))
            let iconName = getImageForTimeLeft(timeLeft, activityStatus.activityTime)
            let icon = NSImage(named: iconName)
            icon?.isTemplate = true
            statusItem.button?.image = icon
            statusItem.button?.contentTintColor = nil
        } else if (AppState.status == Status.Break) {
            let timeLeft = abs(Date().timeIntervalSince(activityStatus.breakTimer.fireDate))
            let iconName = getImageForTimeLeft(timeLeft, activityStatus.breakTime)
            let icon = NSImage(named: iconName)
            icon?.isTemplate = true
            statusItem.button?.image = icon
            statusItem.button?.contentTintColor = NSColor.systemRed
        } else {
            statusItem.button?.image = statusBarIcon
            statusItem.button?.contentTintColor = nil
        }
        
        statusItem.button?.appearsDisabled = AppState.isMuted
    }

    func getImageForTimeLeft(_ timeLeft: TimeInterval, _ base: Double) -> String {
        let timePercent = timeLeft / base
        return String(Int(round((1 - timePercent) * 12)))
    }
}
