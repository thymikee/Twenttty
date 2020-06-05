//
//  AppState.swift
//  Twenttty
//
//  Created by Michał Pierzchała on 03/06/2020.
//  Copyright © 2020 Michał Pierzchała. All rights reserved.
//

import Foundation
import LaunchAtLogin

final class AppState {
    static var isMuted: Bool = false
    static var status: Status = Status.Inactive
    static var launchAtLogin: Bool = LaunchAtLogin.isEnabled

    private init() {}

    static func setIsMuted(_ value: Bool) {
        isMuted = value
    }

    static func setStatus(_ value: Status) {
        status = value
    }

    static func setLaunchAtLogin(_ value: Bool) {
        launchAtLogin = value
        LaunchAtLogin.isEnabled = value
    }
}
