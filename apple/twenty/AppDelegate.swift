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
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        _ = StatusBar(activityStatus)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        activityStatus.dispose()
    }
}

