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
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.button?.title = "👀"
        statusItem.button?.target = self
        statusItem.button?.action = #selector(showSettings)
        
//        // Check if the launcher app is started
//        var startedAtLogin = false
//        for app in NSWorkspace.shared().runningApplications {
//            if app.bundleIdentifier == NCConstants.launcherApplicationIdentifier {
//                startedAtLogin = true
//            }
//        }
//
//        // If the app's started, post to the notification center to kill the launcher app
//        if startedAtLogin {
//            DistributedNotificationCenter.default().postNotificationName(NCConstants.KILLME, object: Bundle.main.bundleIdentifier, userInfo: nil, options: DistributedNotificationCenter.Options.deliverImmediately)
//        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc func showSettings() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: "ViewController") as? ViewController else {
            fatalError("Unable to find ViewController")
        }
        
        let popoverView = NSPopover()
        popoverView.contentViewController = vc
        popoverView.behavior = .transient
        popoverView.show(relativeTo: statusItem.button!.bounds, of: statusItem.button!, preferredEdge: .maxY )
    }
}

