//
//  GlobalMode.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/4/19.
//

import Foundation
import AppKit
import Defaults
import AXSwift
import AXSwiftExt

class GlobalMode {
    static let shared = GlobalMode()
    
    private var eventTap: CFMachPort? = nil
    private var observation: Any? = nil

    func initialize() {
        // listen new copy
        NSPasteboard.general.onNewCopy { newItem in
            guard Defaults[.isOn] else {
                return
            }
            print("on new copy", NSPasteboard.general.pasteboardItems?.count)
            if NSPasteboard.general.pasteboardItems?.isEmpty != true {
                NSPasteboard.safeCopy.setString(nil)
            }
        }
        overrideCopyPaste()
        observation = Defaults.observe(keys: .isOn, .overrideShortcuts) {
            if Defaults[.isOn], Defaults[.overrideShortcuts] {
                print("overrides")
                self.overrideCopyPaste()
            } else {
                print("do not overrides")
                self.unoverrideCopyPaste()
            }
        }
    }
    
    func overrideCopyPaste() {
        unoverrideCopyPaste()
        // 监听粘贴
        eventTap = listenAndInterceptKeyEvent(events: [.keyDown]) { proxy, type, event, _ in
            guard Defaults[.isOn], Defaults[.overrideShortcuts] else {
                return Unmanaged.passRetained(event)
            }
            
            print("first", event.flags.contains(.maskCommand), event.getIntegerValueField(.keyboardEventKeycode))
            
            // 粘贴
            NSLog("event.flags \(event.flags.check(is: .maskCommand))")
            if event.flags.check(is: .maskCommand) && event.getIntegerValueField(.keyboardEventKeycode) == 9 {
                // 检查上一次复制是否通过代理
                if let value = NSPasteboard.safeCopy.string() {
                    if let item = canPerformPaste() {
                        try? item.performAction(.press)
                    }
                    return nil
                }
            }
            
            // 复制
            if event.flags.check(is: .maskCommand) && event.getIntegerValueField(.keyboardEventKeycode) == 8 {
                if let item = canPerformCopy() {
                    try? item.performAction(.press)
                    NSPasteboard.general.clearContents()
                    return nil
                }
            }
            // 处理事件的回调函数
            return Unmanaged.passRetained(event)
        }
    }
    
    func unoverrideCopyPaste() {
        if let eventTap {
            unlistenKeyEvent(eventTap)
        }
        eventTap = nil
    }
}

extension CGEventFlags {
    private var modifiers: CGEventFlags {
        self.intersection([.maskCommand, .maskShift, .maskControl, .maskAlternate])
    }
    
    func check(is flag: CGEventFlags) -> Bool {
        modifiers.symmetricDifference(flag).isEmpty
    }
}

