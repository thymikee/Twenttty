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
    let activityStatus = ActivityStatus()

    override init() {
        super.init()
        
        activityStatus.delegate = self
        updateStatusItemImage()
    }

    func onActivityChange(_ sender: ActivityStatus) {
        updateStatusItemImage()
    }

    func updateStatusItemImage() {
        statusItem.button?.image = getIcon(AppState.status)
        if #available(macOS 11, *) {
            // macOS Big Sur doesn't respect contentTintColor in NSStatusItemButton, fall back to changing opacity
            statusItem.button?.alphaValue = AppState.status == Status.Break ? 0.7 : 1
        } else {
            statusItem.button?.contentTintColor = AppState.status == Status.Break ? NSColor.systemRed : nil
        }

        statusItem.button?.appearsDisabled = AppState.isMuted
    }
    
    func getIcon(_ status: Status) -> NSImage? {
        var iconName: String = "12";
        if (status == Status.Active) {
            let timeLeft = abs(Date().timeIntervalSince(activityStatus.activityTimer.fireDate))
            iconName = getImageForTimeLeft(timeLeft, activityStatus.activityTime)
        } else if (status == Status.Break) {
            let timeLeft = abs(Date().timeIntervalSince(activityStatus.breakTimer.fireDate))
            iconName = getImageForTimeLeft(timeLeft, activityStatus.breakTime)
        }
        let icon = NSImage(named: iconName)
        icon?.isTemplate = true
        return icon
    }

    func getImageForTimeLeft(_ timeLeft: TimeInterval, _ base: Double) -> String {
        let timePercent = timeLeft / base
        return String(Int(round((1 - timePercent) * 12)))
    }
}
