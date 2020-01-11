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
    
    func register() {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            self.isGranted = granted
        }
    }
    
    func schedule() {
        if (!isGranted) {
            NSSound(named: "Autopilot Engage.wav")?.play()
            return
        }
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.title = "Break time!"
        content.body = getRandomNotificationBody()
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "Autopilot Engage.wav"))
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
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
            return "Is it a plane? Is it a bird? It's something outside to look at"
        case 8:
            return "Relax, take it easy"
        case 9:
            return "Just look away please, sky is the limit"
        default:
            return "Look at something 6m or further away from you"
        }
    }
}
