//
//  AppDelegate.swift
//  Twenttty
//
//  Created by Michał Pierzchała on 25/12/2019.
//  Copyright © 2019 Michał Pierzchała. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBar: StatusBar?
    var mainView: ViewController?
    @IBOutlet weak var menu: NSMenu?
    @IBOutlet weak var firstMenuItem: NSMenuItem?
    @IBOutlet weak var menuMuted: NSMenuItem!
    @IBOutlet weak var menuLaunchAtLogin: NSMenuItem!
    @IBOutlet weak var menuNotifications: NSMenuItem!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupStatusBar()
        setupMenu()
    }
    
    func setupStatusBar() {
        statusBar = StatusBar()
    }
    
    func setupMenu() {
        menu?.delegate = self
        mainView = getView()
        firstMenuItem?.view = mainView?.view
        
        if let button = statusBar?.statusItem.button {
            button.target = self
            button.action = #selector(self.statusBarButtonClicked(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        setMenuMutedState()
        setLaunchAtLoginState()
    }
    
    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        if let event = NSApp.currentEvent, event.type == NSEvent.EventType.leftMouseUp, event.modifierFlags.contains(.option) {
            onMenuSoundsPress(nil)
        } else {
            statusBar?.statusItem.menu = menu
            statusBar?.statusItem.button?.performClick(nil)
        }
    }
    
    func setMenuMutedState() {
        menuMuted.state = AppState.isMuted ? NSControl.StateValue.on : NSControl.StateValue.off
        statusBar?.activityStatus.onActivityChange()
    }
    
    func setLaunchAtLoginState() {
        menuLaunchAtLogin.state = AppState.launchAtLogin ? NSControl.StateValue.on : NSControl.StateValue.off
    }
    
    @IBAction func onMenuSoundsPress(_ sender: NSMenuItem?) {
        AppState.setIsMuted(!AppState.isMuted)
        setMenuMutedState()
    }
    
    @IBAction func onMenuLaunchAtLoginPress(_ sender: NSMenuItem) {
        AppState.setLaunchAtLogin(!AppState.launchAtLogin)
        setLaunchAtLoginState()
    }
    
    @IBAction func onMenuNotificationsPress(_ sender: NSMenuItem) {
        NSWorkspace.shared.open(URL(fileURLWithPath: "x-apple.systempreferences:com.apple.preference.notifications"))
    }
    
    func getView() -> ViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: "ViewController") as? ViewController else {
            fatalError("Unable to find ViewController")
        }
        vc.activityStatus = statusBar?.activityStatus
        return vc
    }
}

extension AppDelegate: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        mainView?.setup()
        
        statusBar?.activityStatus.breakNotification.requestNotificationPermission() { granted in
            menu.items.forEach({ menuItem in
                if (menuItem.identifier?.rawValue == "menuNotifications") {
                    menuItem.isHidden = granted
                }
            })
        }
    }
    
    func menuDidClose(_ menu: NSMenu) {
        mainView?.teardown()
        // menu must be nil for statusItem.button action to be actionable
        statusBar?.statusItem.menu = nil
    }
}
