//
//  UserDefaultsKey.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/4/13.
//

import Foundation
import Defaults

extension Defaults.Keys {

    static let showQuickActions = Key<Bool>("showQuickActions", default: false)
    static let globalMode = Key<Bool>("globalMode", default: false)
    static let manualMode = Key<Bool>("manualMode", default: true)
}
