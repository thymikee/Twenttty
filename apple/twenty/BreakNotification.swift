//
//  Notification.swift
//  twenty
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
        content.title = "Break time!"
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
        switch random {
        case 0:
            return "Close your eyes, make a wish, now count to 20"
        case 1:
            return "Look away from the display"
        case 2:
            return "Find something to look at behind a window"
        case 3:
            return "Find something at least 6m away from you"
        case 4:
            return "Point your eyeballs somewhere further"
        case 5:
            return "Give your eyes 20s to relax"
        case 6:
            return "Look at something far away for 20s"
        case 7:
            return "Is it a plane? Is it a bird? Maybe, take a look"
        case 8:
            return "Relax, take it easy"
        case 9:
            return "Just look away please, sky is the limit"
        default:
            return "Look at something 6m or further away from you"
        }
    }
}
