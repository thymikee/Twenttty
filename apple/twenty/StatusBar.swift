//
//  StatusBar.swift
//  twenty
//
//  Created by Michał Pierzchała on 24/05/2020.
//  Copyright © 2020 Michał Pierzchała. All rights reserved.
//

import Cocoa

class StatusBar: ActivityStatusDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let statusBarIcon = NSImage(named: "12")
    let popover = NSPopover()
    let activityStatus = ActivityStatus()
    
    init() {
        activityStatus.delegate = self
        initStatusBarIcon()
    }

    func initStatusBarIcon() {
        statusBarIcon?.isTemplate = true
        statusItem.button?.image = statusBarIcon
        statusItem.button?.target = self
        statusItem.button?.action = #selector(togglePopover)
    }
    
    func onActivityChange(_ sender: ActivityStatus) {
        updateStatusItemImage()
    }

    func updateStatusItemImage() {
        if (activityStatus.activityTimer.isValid) {
            let timeLeft = abs(Date().timeIntervalSince(activityStatus.activityTimer.fireDate))
            let iconName = getImageForTimeLeft(timeLeft, activityStatus.activityTime)
            let icon = NSImage(named: iconName)
            icon?.isTemplate = true
            statusItem.button?.image = icon
            statusItem.button?.contentTintColor = nil
        } else if (activityStatus.breakTimer.isValid) {
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
        
        if (activityStatus.breakNotification.isMuted) {
            statusItem.button?.contentTintColor = NSColor.systemGray
        }
    }

    func getImageForTimeLeft(_ timeLeft: TimeInterval, _ base: Double) -> String {
        let timePercent = timeLeft / base
        return String(Int(floor((1 - timePercent) * 12)))
    }

    func getMainView() -> ViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: "ViewController") as? ViewController else {
            fatalError("Unable to find ViewController")
        }
        vc.activityStatus = activityStatus
        return vc
    }
    
    @objc func togglePopover() {
        if (popover.isShown) {
            popover.close()
        } else {
            popover.contentViewController = getMainView()
            popover.behavior = .transient
            popover.show(relativeTo: statusItem.button!.bounds, of: statusItem.button!, preferredEdge: .maxY )
        }
    }
}
