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
    @IBOutlet weak var menu: NSMenu?
    @IBOutlet weak var firstMenuItem: NSMenuItem?
    @IBOutlet weak var menuSounds: NSMenuItem!
    @IBOutlet weak var menuLaunchAtLogin: NSMenuItem!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupStatusBar()
    }
    
    func setupStatusBar() {
        toggleMenuSoundsState()
        toggleLaunchAtLoginState()
        statusBar = StatusBar(menu, firstMenuItem)
    }
    
    func toggleMenuSoundsState() {
        menuSounds.state = AppState.isMuted ? NSControl.StateValue.off : NSControl.StateValue.on
    }
    
    func toggleLaunchAtLoginState() {
        menuLaunchAtLogin.state = AppState.launchAtLogin ? NSControl.StateValue.on : NSControl.StateValue.off
    }
    
    @IBAction func onMenuSoundsPress(_ sender: NSMenuItem) {
        AppState.setIsMuted(!AppState.isMuted)
        toggleMenuSoundsState()
        statusBar?.activityStatus.onActivityChange()
    }
    @IBAction func onMenuLaunchAtLoginPress(_ sender: NSMenuItem) {
        AppState.setLaunchAtLogin(!AppState.launchAtLogin)
        toggleLaunchAtLoginState()
    }
}

