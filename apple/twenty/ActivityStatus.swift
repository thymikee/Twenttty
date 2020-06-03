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
    var activityCheckInterval: Double = 5
    var activityTime: Double = 60 * 20
    var breakTime: Double = 20
    var systemEventsCount: UInt32 = 0
    var activityMonitorTimer = Timer()
    var activityTimer = Timer()
    var breakTimer = Timer()
    var clockUITimer = Timer()
    var breakNotification = BreakNotification()
    var delegate: ActivityStatusDelegate?
    
    init() {
        systemEventsCount = getSystemEventsCount()
        subscribeToLockScreen()
        startActivityMonitoring()
    }
    
    deinit {
        invalidateTimers()
    }
    
    func subscribeToLockScreen() {
        let dnc = DistributedNotificationCenter.default()

        dnc.addObserver(forName: .init("com.apple.screenIsLocked"), object: nil, queue: .main) { _ in
            AppState.setStatus(Status.Inactive)
            self.invalidateTimers()
        }
        
        dnc.addObserver(forName: .init("com.apple.screenIsUnlocked"), object: nil, queue: .main) { _ in
            self.startInactivity()
        }
    }
    
    func startActivityMonitoring() {
        self.systemEventsCount = self.getSystemEventsCount()
        activityMonitorTimer = Timer.scheduledTimer(withTimeInterval: activityCheckInterval, repeats: true, block: { _ in
            if (self.systemEventsCount != self.getSystemEventsCount()) {
                self.startActivity()
            }
        })
    }
    
    func invalidateTimers() {
        activityMonitorTimer.invalidate()
        activityTimer.invalidate()
        clockUITimer.invalidate()
        breakTimer.invalidate()
    }
    
    func startActivity() {
        invalidateTimers()
        AppState.setStatus(Status.Active)
        activityTimer = Timer.scheduledTimer(withTimeInterval: activityTime, repeats: false, block: { _ in
            self.startBreak()
        })
        clockUITimer = Timer.scheduledTimer(withTimeInterval: activityTime / 12, repeats: true, block: { _ in
            self.onActivityChange()
        })
        onActivityChange()
    }
    
    func startBreak() {
        invalidateTimers()
        AppState.setStatus(Status.Break)
        breakNotification.startBreak()
        breakTimer = Timer.scheduledTimer(withTimeInterval: breakTime, repeats: false, block: { _ in
            self.breakNotification.endBreak()
            self.startInactivity()
        })
        clockUITimer = Timer.scheduledTimer(withTimeInterval: breakTime / 12, repeats: true, block: { _ in
            self.onActivityChange()
        })
        onActivityChange()
    }
    
    func startInactivity() {
        AppState.setStatus(Status.Inactive)
        startActivityMonitoring()
        onActivityChange()
    }
    
    func onActivityChange() {
        delegate?.onActivityChange(self)
    }

    func getSystemEventsCount() -> UInt32 {
        return CGEventSource.counterForEventType(CGEventSourceStateID.combinedSessionState, eventType: CGEventType.mouseMoved) + CGEventSource.counterForEventType(CGEventSourceStateID.combinedSessionState, eventType: CGEventType.keyDown)
    }
}
