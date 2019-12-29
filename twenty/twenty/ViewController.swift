//
//  ViewController.swift
//  twenty
//
//  Created by Michał Pierzchała on 25/12/2019.
//  Copyright © 2019 Michał Pierzchała. All rights reserved.
//

import Cocoa
import UserNotifications
import LaunchAtLogin

enum Status {
    case Inactive
    case Active
    case Break
}

class ViewController: NSViewController, NSTextFieldDelegate {
    @IBOutlet weak var output: NSTextField!
    var activityCheckInterval: Double = 1
    var activityTime: Double = 10 // 60 * 20
    var breakTime: Double = 5 // 20
    var systemEventsCount: UInt32 = 0
    var activityTimer: Timer = Timer()
    var breakTimer: Timer = Timer()
    var activityStatus: Status = Status.Inactive
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(LaunchAtLogin.isEnabled)
        //=> false

        LaunchAtLogin.isEnabled = true

        print(LaunchAtLogin.isEnabled)
        //=> true
        
        initialize()
        
        registerNotifications()
        
        Timer.scheduledTimer(withTimeInterval: activityCheckInterval, repeats: true, block: { _ in
            print(self.activityStatus)
            if (self.activityStatus == Status.Break) {
                //
            } else if (self.systemEventsCount != self.getSystemEventsCount()) {
                if (self.activityStatus != Status.Active) {
                    self.startActivityTimer()
                }
                self.activityStatus = Status.Active
            }
            
            self.initialize()
        })
    }
    
    func initialize() {
        systemEventsCount = getSystemEventsCount()
    }
    
    func startActivityTimer() {
        NSLog("activity detected")
        invalidateActivityTimer()
        
        activityTimer = Timer.scheduledTimer(withTimeInterval: activityTime, repeats: false, block: { _ in
            self.startBreak()
        })
    }
    
    func invalidateActivityTimer() {
        activityTimer.invalidate()
    }
    
    func startBreak() {
        NSLog("break")
        activityStatus = Status.Break
        scheduleNotification()
        breakTimer = Timer.scheduledTimer(withTimeInterval: breakTime, repeats: false, block: { _ in
            NSLog("break end")
            self.activityStatus = Status.Inactive
        })
    }
    
    func registerNotifications() {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }
    
    func scheduleNotification() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.body = "Time for an eye break"
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }

    func getSystemEventsCount() -> UInt32 {
        return CGEventSource.counterForEventType(CGEventSourceStateID.combinedSessionState, eventType: CGEventType.mouseMoved)
    }
}

