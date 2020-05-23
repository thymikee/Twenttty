//
//  ActivityStatusDelegate.swift
//  twenty
//
//  Created by Michał Pierzchała on 23/05/2020.
//  Copyright © 2020 Michał Pierzchała. All rights reserved.
//

import Foundation

protocol ActivityStatusDelegate {
    func onActivityChange(_ sender: ActivityStatus)
}
