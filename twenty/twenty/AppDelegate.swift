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
        let initialTitle = "👀"
        statusItem.button?.title = initialTitle
        statusItem.button?.target = self
        statusItem.button?.action = #selector(showSettings)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            if (self.activityStatus.status == Status.Break && self.activityStatus.breakTimer.isValid) {
                let formatter = DateComponentsFormatter()
                formatter.unitsStyle = .positional
                formatter.allowedUnits = [.minute, .second]
                formatter.zeroFormattingBehavior = .pad
                
                let now = Date()
                let targetDate = self.activityStatus.breakTimer.fireDate
                let formattedTimeLeft = formatter.string(from: now, to: targetDate) ?? ""
                
                self.statusItem.button?.title = formattedTimeLeft + " " + initialTitle
            } else {
                self.statusItem.button?.title = initialTitle
            }
        })
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

