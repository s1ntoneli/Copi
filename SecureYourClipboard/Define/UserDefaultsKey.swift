//
//  UserDefaultsKey.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/4/13.
//

import Foundation
import Defaults

extension Defaults.Keys {

    static let showQuickActions = Key<Bool>("showQuickActions", default: true)
    static let overrideShortcuts = Key<Bool>("overrideShortcuts", default: false)
    static let isOn = Key<Bool>("isOn", default: true)
    static let isServicesPermitted = Key<Bool>("isServicesPermitted", default: false)
}
