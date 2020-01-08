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
        let icon = NSImage(named: "0")
        icon?.isTemplate = true
        statusItem.button?.image = icon
        statusItem.button?.target = self
        statusItem.button?.action = #selector(showSettings)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            if (self.activityStatus.activityTimer.isValid) {
                let timeLeft = abs(Date().timeIntervalSince(self.activityStatus.activityTimer.fireDate))
                let iconName = self.getImageForTimeLeft(timeLeft, self.activityStatus.activityTime)
                let icon = NSImage(named: iconName)
                icon?.isTemplate = true
                self.statusItem.button?.image = icon
                self.statusItem.button?.contentTintColor = nil
            } else if (self.activityStatus.breakTimer.isValid) {
                let timeLeft = abs(Date().timeIntervalSince(self.activityStatus.breakTimer.fireDate))
                let iconName = self.getImageForTimeLeft(timeLeft, self.activityStatus.breakTime)
                let icon = NSImage(named: iconName)
                icon?.isTemplate = true
                self.statusItem.button?.image = icon
                self.statusItem.button?.contentTintColor = NSColor.red
            } else {
                self.statusItem.button?.image = icon
                self.statusItem.button?.contentTintColor = nil
            }
        })
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

