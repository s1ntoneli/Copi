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
            copyByService()
            
//            NSPasteboard.general.safeCopyPlainTextValue = NSPasteboard.general.selectedTextValue
//            print("safe copy", NSPasteboard.general.safeCopyPlainTextValue)
        }
        KeyboardShortcuts.onKeyUp(for: .safePaste) {
            guard Defaults[.manualMode] else {
                return
            }
            
            pasteByService()
            //            if let text = NSPasteboard.general.safeCopyPlainTextValue {
            //                print("safe paste", text)
            //                pastePrivacy(text)
            //            }
            //            let pboard = NSPasteboard(name: NSPasteboard.Name(rawValue: "obc"))
            //            pboard.setString("obbb", forType: .string)
            //            let service = NSSharingService(named: NSSharingService.Name(rawValue: "Test Process Text2"))!
            //
            //            service.canPerform(withItems: [])
            ////            let result = NSPerformService("Test Process Text2", nil)
            //            print("perform", service.canPerform(withItems: []))
//            print("servicesMenu", NSApp.servicesMenu?.items.count)
            
            //            NSApplication.shared.servicesMenu?.items.forEach({ item in
            //                print("item \(item.title)")
            //            })
//            let item = NSApp.servicesMenu?.items.first(where: { $0.title == "Test Process Text2" })
//            print("enable", item?.isEnabled, item?.isAlternate, item?.isHidden, item?.representedObject)
        }
        
        MouseEventCatcher.shared.onSelectEventHooks { event in
            let text = getSelectedText()
            NSPasteboard.general.selectedTextValue = text
            print("get", text)
            if let text, Defaults[.showQuickActions] {
                PopupWindowController.shared.showWindowAt(event.locationInWindow, text)
            } else {
                PopupWindowController.shared.closeWindow()
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
        print("processed", pasteboard.name)
        guard let content = pasteboard.string(forType: .string) else { return }
        print("processSelectedText", content, pasteboard.changeCount)
        // Use `content`…
        pasteboard.clearContents()
        print("cleared", pasteboard.changeCount)
        pasteboard.setString("processed", forType: .string)
        print("set new", pasteboard.changeCount)
    }

    @objc func copyText(_ pasteboard: NSPasteboard, userData: String?, error: NSErrorPointer) {
        print("copyText", pasteboard.name)
        guard let content = pasteboard.string(forType: .string) else { return }
        // Use `content`…
        NSPasteboard.general.safeCopyPlainTextValue = content
        print("copyText content:", content)
        pasteboard.clearContents()
        pasteboard.setString("", forType: .fromSecureClipX)
    }

    @objc func pasteText(_ pasteboard: NSPasteboard, userData: String?, error: NSErrorPointer) {
        print("pasteText", pasteboard.name)
        // Use `content`…
        pasteboard.clearContents()
        pasteboard.setString(NSPasteboard.general.safeCopyPlainTextValue ?? "", forType: .string)
        print("pasteText", NSPasteboard.general.safeCopyPlainTextValue ?? "")
    }
}
