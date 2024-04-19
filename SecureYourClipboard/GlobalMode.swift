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

    func initialize() {
        // 监听复制
        Clipboard.shared.onNewCopy { newItem in
            print("on new copy", NSPasteboard.general.pasteboardItems!.count)
            if Defaults[.globalMode], let items = NSPasteboard.general.pasteboardItems, !items.isEmpty, !items.contains(where: { $0.types.contains(.fromSecureClipX) }) {
                print("not empty")
                if items.contains(where: { $0.types.contains(.string) }) {
                    print("contains string")
                    measureTime {
                        NSPasteboard.general.saveToSafeCopyValue()
                        NSPasteboard.general.clearContents()
                    }
                }
            }
        }
        
        // 监听粘贴
        listenAndInterceptKeyEvent(events: [.keyDown]) { proxy, type, event, _ in
            guard Defaults[.globalMode] else {
                return Unmanaged.passRetained(event)
            }
            
            print("first", event.flags.contains(.maskCommand), event.getIntegerValueField(.keyboardEventKeycode))
            
            // 粘贴
            NSLog("event.flags \(event.flags.check(is: .maskCommand))")
            if event.flags.check(is: .maskCommand) && event.getIntegerValueField(.keyboardEventKeycode) == 9 {
                // 检查上一次复制是否通过代理
                if !NSPasteboard.general.pasteboardItems!.isEmpty || NSPasteboard.general.safeCopyValue == nil {
                    return Unmanaged.passRetained(event)
                }

                // 代理复制的文字内容
                NSPasteboard.general.onPrivateMode {
                    //                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.writeObjects(NSPasteboard.general.safeCopyValue ?? [])
//                    callSystemPaste()
                    if let app = Application(NSRunningApplication.current), let paste = app.deepFirst(where: { $0.identifier == "paste:" || ($0.cmdChar == "V" && $0.cmdModifiers == 0) }) {
                        print("found paste")
                        try? paste.performAction(.press)
                    }

                    NSPasteboard.general.safeCopyValue = NSPasteboard.general.safeCopyValue.copy()
                }
                return nil
            }
            // 处理事件的回调函数
            return Unmanaged.passRetained(event)
        }
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

