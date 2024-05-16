//
//  Security.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/3/28.
//

import Foundation
import AppKit

func interceptCopy(_ items: [NSPasteboardItem], filters: [SensitiveDataRegexModel]) {
    items.forEach({ item in
        let types = Set(item.types)
        if types.contains(.string) {
            if let value = item.string(forType: .string) {
                let newValue = filters.reduce(value, { $1.filter($0) })
                if newValue != value {
                    NSPasteboard.general.copy(newValue, updateChangeCount: true)
                }
            }
        }
    })
}
