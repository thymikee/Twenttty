//
//  ActivityStatus.swift
//  twenty
//
//  Created by Michał Pierzchała on 29/12/2019.
//  Copyright © 2019 Michał Pierzchała. All rights reserved.
//

import Foundation
import AppKit

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
    var breakNotification = BreakNotification()
    
    init() {
        systemEventsCount = getSystemEventsCount()
        breakNotification.register()
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
        breakNotification.schedule()
        breakTimer = Timer.scheduledTimer(withTimeInterval: breakTime, repeats: false, block: { _ in
            self.status = Status.Inactive
            
            if (self.breakNotification.isMuted) {
                return
            }
            
            NSSound(named: "Autopilot Disengage.wav")?.play()
        })
    }

    func getSystemEventsCount() -> UInt32 {
        return CGEventSource.counterForEventType(CGEventSourceStateID.combinedSessionState, eventType: CGEventType.mouseMoved) + CGEventSource.counterForEventType(CGEventSourceStateID.combinedSessionState, eventType: CGEventType.keyDown)
    }
}
