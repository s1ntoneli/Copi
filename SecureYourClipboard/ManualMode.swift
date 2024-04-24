//
//  ManualMode.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/4/19.
//

import Foundation
import KeyboardShortcuts
import AppKit
import Defaults

class ManualMode {
    static let shared = ManualMode()

    func initialize() {
        KeyboardShortcuts.onKeyUp(for: .safeCopy) {
            guard Defaults[.manualMode] else {
                return
            }
            guard !Defaults[.globalMode] else {
                return
            }
            copyByService()
            
//            NSPasteboard.general.safeCopyPlainTextValue = NSPasteboard.general.selectedTextValue
//            print("safe copy", NSPasteboard.general.safeCopyPlainTextValue)
        }
        KeyboardShortcuts.onKeyUp(for: .safePaste) {
            guard Defaults[.manualMode] else {
                return
            }
            guard !Defaults[.globalMode] else {
                return
            }
            
            pasteByService()
        }
        
        MouseEventCatcher.shared.onSelectEventHooks { event in
            Task {
                let text = getSelectedText()
                NSPasteboard.general.selectedTextValue = text
                print("get", text)
                if let text, Defaults[.showQuickActions] {
                    await PopupWindowController.shared.showWindowAt(event.locationInWindow, text)
                } else {
                    await PopupWindowController.shared.closeWindow()
                }
            }
        }
        MouseEventCatcher.shared.onUnSelectEventHooks { event in
            PopupWindowController.shared.closeWindow()
        }
        //        runService()
        NSApp.servicesProvider = self
        NSUpdateDynamicServices()
    }
    
    @objc func processSelectedText(_ pasteboard: NSPasteboard, userData: String?, error: NSErrorPointer) {
        print("processSelectedText", pasteboard.name)
        guard let content = pasteboard.string(forType: .string) else { return }
        // Use `content`…
        NSPasteboard.selected.setString(content)
        print("processSelectedText content:", content)
        
        pasteboard.clearContents()
        pasteboard.setString("", forType: .fromSecureClipX)
    }

    @objc func copyText(_ pasteboard: NSPasteboard, userData: String?, error: NSErrorPointer) {
        log(.info, pasteboard.name.rawValue)
        guard let content = pasteboard.string(forType: .string) else { return }
        // Use `content`…
        NSPasteboard.safeCopy.setString(content)
        print("copyText content:", content)
        // need to set the return data, otherwise the focus will leave the foreground app after the service call is completed
        pasteboard.clearContents()
        pasteboard.setString("", forType: .fromSecureClipX)
    }

    @objc func pasteText(_ pasteboard: NSPasteboard, userData: String?, error: NSErrorPointer) {
        print("pasteText", pasteboard.name)
        // Use `content`…
        pasteboard.clearContents()
        pasteboard.setString(NSPasteboard.safeCopy.string() ?? "", forType: .string)
        print("pasteText", NSPasteboard.safeCopy.string() ?? "")
    }
}
