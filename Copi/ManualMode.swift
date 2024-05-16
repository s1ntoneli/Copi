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
import AXSwift

class ManualMode {
    static let shared = ManualMode()

    func initialize() {
        KeyboardShortcuts.onKeyUp(for: .safeCopy) {
            guard Defaults[.isOn], !Defaults[.overrideShortcuts] else {
                return
            }
            copyByService()
            PopupWindowController.shared.closeWindow()
        }
        KeyboardShortcuts.onKeyUp(for: .safePaste) {
            guard Defaults[.isOn], !Defaults[.overrideShortcuts] else {
                return
            }

            pasteByService()
            PopupWindowController.shared.closeWindow()
        }
        
        MouseEventCatcher.shared.onSelectEventHooks { event in
            guard AXSwift.checkIsProcessTrusted(), Defaults[.isOn], Defaults[.showQuickActions] else {
                return
            }

            let location = event.locationInWindow
            Task {
                let copyItem = canPerformCopy()
                let pasteItem = canPerformPaste()
                let canCopy = copyItem != nil
                let canPaste = pasteItem != nil && NSPasteboard.safeCopy.string() != nil
                
                if canCopy || canPaste {
                    await PopupWindowController.shared.showWindowAt(location, copyItem: copyItem, pasteItem: pasteItem)
                } else {
                    await PopupWindowController.shared.closeWindow()
                }
            }
        }
        MouseEventCatcher.shared.onUnSelectEventHooks { event in
            PopupWindowController.shared.closeWindow()
        }
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
        pasteboard.setString("", forType: .fromCopi)
    }

    @objc func copyText(_ pasteboard: NSPasteboard, userData: String?, error: NSErrorPointer) {
        log(.info, pasteboard.name.rawValue)
        guard let content = pasteboard.string(forType: .string) else { return }
        // Use `content`…
        NSPasteboard.safeCopy.setString(content)
        print("copyText content:", content)
    }

    @objc func pasteText(_ pasteboard: NSPasteboard, userData: String?, error: NSErrorPointer) {
        print("pasteText", pasteboard.name)
        // Use `content`…
        pasteboard.clearContents()
        pasteboard.setString(NSPasteboard.safeCopy.string() ?? "", forType: .string)
        print("pasteText", NSPasteboard.safeCopy.string() ?? "")
    }
}
