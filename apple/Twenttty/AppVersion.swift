//
//  AppVersion.swift
//  Twenttty
//
//  Created by Michał Pierzchała on 24/05/2020.
//  Copyright © 2020 Michał Pierzchała. All rights reserved.
//

import Foundation

class AppVersion {
    func getVersion() -> String {
        let name = Bundle.main.infoDictionary!["CFBundleName"] as! String
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        return name + " v" + version
    }
}
