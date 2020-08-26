//
//  Notification.swift
//  Twenttty
//
//  Created by Michał Pierzchała on 10/01/2020.
//  Copyright © 2020 Michał Pierzchała. All rights reserved.
//

import Foundation
import AppKit
import UserNotifications

class BreakNotification {
    var isGranted: Bool = false
    let startBreakSoundName = "StartBreak.wav"
    let endBreakSoundName = "EndBreak.wav"

    init() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            self.isGranted = granted
        }
    }

    deinit {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }

    func startBreak() {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notification_title", comment: "")
        content.body = getRandomNotificationBody()
        content.sound = UNNotificationSound(named: UNNotificationSoundName(startBreakSoundName))

        scheduleNotification(content: content, fallbackSound: startBreakSoundName)
    }

    func endBreak() {
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound(named: UNNotificationSoundName(endBreakSoundName))

        scheduleNotification(content: content, fallbackSound: endBreakSoundName)
    }

    func scheduleNotification(content: UNMutableNotificationContent, fallbackSound: String) {
        if (AppState.isMuted) {
            return
        }

        if (!isGranted) {
            NSSound(named: fallbackSound)?.play()
            return
        }

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        let center = UNUserNotificationCenter.current()

        center.add(request) { (error : Error?) in
            if error != nil {
                // no need to handle for now
            }
        }
    }

    func getRandomNotificationBody() -> String {
        let random = Int.random(in: 0...10)
        return NSLocalizedString("notification_content_" + String(random), comment: "")
    }
}
