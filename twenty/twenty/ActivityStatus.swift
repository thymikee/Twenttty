//
//  ActivityStatus.swift
//  twenty
//
//  Created by Michał Pierzchała on 29/12/2019.
//  Copyright © 2019 Michał Pierzchała. All rights reserved.
//

import Foundation
import UserNotifications
import LaunchAtLogin

enum Status {
    case Inactive
    case Active
    case Break
}

class ActivityStatus {
    let activityCheckInterval: Double = 1
    let activityTime: Double = 10 // 60 * 20
    let breakTime: Double = 5 // 20
    var systemEventsCount: UInt32 = 0
    var activityMonitorTimer: Timer = Timer()
    var activityTimer: Timer = Timer()
    var breakTimer: Timer = Timer()
    var activityStatus: Status = Status.Inactive
    
    init() {
        systemEventsCount = getSystemEventsCount()
        registerNotifications()
        startActivityMonitoring()
    }
    
    func dispose() {
        activityMonitorTimer.invalidate()
        activityTimer.invalidate()
        breakTimer.invalidate()
    }
    
    func startActivityMonitoring() {
        activityMonitorTimer = Timer.scheduledTimer(withTimeInterval: activityCheckInterval, repeats: true, block: { _ in
            if (self.activityStatus == Status.Break) {
                //
            } else if (self.systemEventsCount != self.getSystemEventsCount()) {
                if (self.activityStatus != Status.Active) {
                    self.startActivity()
                }
                self.activityStatus = Status.Active
            }
            
            self.systemEventsCount = self.getSystemEventsCount()
        })
    }
    
    func startActivity() {
        NSLog("activity")
        activityTimer.invalidate()
        
        activityTimer = Timer.scheduledTimer(withTimeInterval: activityTime, repeats: false, block: { _ in
            self.startBreak()
        })
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
            // TODO handle
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
