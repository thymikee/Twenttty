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
    let popover = NSPopover()
    let activityStatus = ActivityStatus()
    var mainMenu: NSMenu?
    var firstMenuItem: NSMenuItem?
    var mainView: ViewController?

    init(_ menu: NSMenu?, _ firstMenuItem: NSMenuItem?) {
        super.init()
        
        if let menu = menu {
            mainMenu = menu
            statusItem.menu = menu
            menu.delegate = self
        }
        
        if let item = firstMenuItem {
            mainView = getView()
            item.view = mainView?.view
        }

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

        if (AppState.isMuted) {
            statusItem.button?.contentTintColor = NSColor.disabledControlTextColor
        }
    }

    func getImageForTimeLeft(_ timeLeft: TimeInterval, _ base: Double) -> String {
        let timePercent = timeLeft / base
        return String(Int(round((1 - timePercent) * 12)))
    }

    func getView() -> ViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: "ViewController") as? ViewController else {
            fatalError("Unable to find ViewController")
        }
        vc.activityStatus = activityStatus
        return vc
    }
}

extension StatusBar: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        mainView?.setup()
        
        activityStatus.breakNotification.requestNotificationPermission() { granted in
            menu.items.forEach({ menuItem in
                if (menuItem.identifier?.rawValue == "menuNotifications") {
                    menuItem.isHidden = granted
                }
            })
        }
    }
    
    func menuDidClose(_ menu: NSMenu) {
        mainView?.teardown()
    }
}
