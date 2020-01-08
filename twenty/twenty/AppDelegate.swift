//
//  AppDelegate.swift
//  twenty
//
//  Created by Michał Pierzchała on 25/12/2019.
//  Copyright © 2019 Michał Pierzchała. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let activityStatus = ActivityStatus()
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let icon = NSImage(named: "12")
        icon?.isTemplate = true
        statusItem.button?.image = icon
        statusItem.button?.target = self
        statusItem.button?.action = #selector(showSettings)

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.updateStatusItemImage(icon)
        })
    }

    func updateStatusItemImage(_ defaultIcon: NSImage?) {
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
            statusItem.button?.contentTintColor = NSColor.red
        } else {
            statusItem.button?.image = defaultIcon
            statusItem.button?.contentTintColor = nil
        }
    }

    func getImageForTimeLeft(_ timeLeft: TimeInterval, _ base: Double) -> String {
        let timePercent = timeLeft / base
        return String(Int(floor((1 - timePercent) * 12)))
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        activityStatus.dispose()
    }

    @objc func showSettings() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: "ViewController") as? ViewController else {
            fatalError("Unable to find ViewController")
        }

        vc.activityStatus = activityStatus

        let popoverView = NSPopover()
        popoverView.contentViewController = vc
        popoverView.behavior = .transient
        popoverView.show(relativeTo: statusItem.button!.bounds, of: statusItem.button!, preferredEdge: .maxY )
    }
}

