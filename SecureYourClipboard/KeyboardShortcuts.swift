//
//  KeyboardShortcuts.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/4/13.
//

import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let safeCopy = Self("safeCopy", default: .init(.c, modifiers: .option))
    static let safePaste = Self("safePaste", default: .init(.v, modifiers: .option))
}
