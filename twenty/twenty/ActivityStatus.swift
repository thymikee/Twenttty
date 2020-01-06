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

enum Status: String {
    case Inactive
    case Active
    case Break
}

class ActivityStatus {
    var activityCheckInterval: Double = 1
    var activityTime: Double = 60 * 20
    var breakTime: Double = 20
    var systemEventsCount: UInt32 = 0
    var activityMonitorTimer = Timer()
    var activityTimer = Timer()
    var breakTimer = Timer()
    var status: Status = Status.Inactive
    
    init() {
        systemEventsCount = getSystemEventsCount()
        registerNotifications()
        subscribeToLockScreen()
        startActivityMonitoring()
    }
    
    func dispose() {
        status = Status.Inactive
        activityMonitorTimer.invalidate()
        activityTimer.invalidate()
        breakTimer.invalidate()
    }
    
    func subscribeToLockScreen() {
        let dnc = DistributedNotificationCenter.default()

        dnc.addObserver(forName: .init("com.apple.screenIsLocked"), object: nil, queue: .main) { _ in
            self.dispose()
        }
        
        dnc.addObserver(forName: .init("com.apple.screenIsUnlocked"), object: nil, queue: .main) { _ in
            self.startActivityMonitoring()
        }
    }
    
    func startActivityMonitoring() {
        activityMonitorTimer = Timer.scheduledTimer(withTimeInterval: activityCheckInterval, repeats: true, block: { _ in
            if (self.status == Status.Break) {
                // do nothing
            } else if (self.systemEventsCount != self.getSystemEventsCount()) {
                if (self.status != Status.Active) {
                    self.startActivity()
                }
                self.status = Status.Active
            }
            
            self.systemEventsCount = self.getSystemEventsCount()
        })
    }
    
    func startActivity() {
        activityTimer.invalidate()
        activityTimer = Timer.scheduledTimer(withTimeInterval: activityTime, repeats: false, block: { _ in
            self.startBreak()
        })
    }
    
    func startBreak() {
        status = Status.Break
        scheduleNotification()
        breakTimer = Timer.scheduledTimer(withTimeInterval: breakTime, repeats: false, block: { _ in
            self.status = Status.Inactive
            NSSound(named: "Autopilot Disengage.wav")?.play()
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
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "Autopilot Engage.wav"))
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }

    func getSystemEventsCount() -> UInt32 {
        return CGEventSource.counterForEventType(CGEventSourceStateID.combinedSessionState, eventType: CGEventType.mouseMoved) + CGEventSource.counterForEventType(CGEventSourceStateID.combinedSessionState, eventType: CGEventType.keyDown)
    }
}
