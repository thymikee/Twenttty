//
//  AppVersion.swift
//  Twenttty
//
//  Created by Michał Pierzchała on 24/05/2020.
//  Copyright © 2020 Michał Pierzchała. All rights reserved.
//

import Foundation

class AppVersion {
    static func getVersion() -> String {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }
    
    static func getAppName() -> String {
        return Bundle.main.infoDictionary!["CFBundleName"] as! String
    }
}
