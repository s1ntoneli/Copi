//
//  Clipboard.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/3/25.
//

import Foundation
import AppKit

typealias OnNewCopyHook = ([NSPasteboardItem]) -> Void

// last checked changeCount
private var kLastCheckedChangeCount = 0
extension NSPasteboard {
    var lastCheckedChangeCount: Int? {
        get {
            objc_getAssociatedObject(self, &kLastCheckedChangeCount) as? Int ?? 0
        }
        set {
            objc_setAssociatedObject(self, &kLastCheckedChangeCount, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
// OnNewCopyHooks
private var kOnNewCopyHooks = 0
extension NSPasteboard {
    var onNewCopyHooks: [OnNewCopyHook] {
        get {
            objc_getAssociatedObject(self, &kOnNewCopyHooks) as? [OnNewCopyHook] ?? []
        }
        set {
            objc_setAssociatedObject(self, &kOnNewCopyHooks, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension NSPasteboard {

    private var timerInterval: TimeInterval { 0.02 }
    private var pasteboard: NSPasteboard { self }
//
//    private var accessibilityAlert: NSAlert {
//        let alert = NSAlert()
//        alert.alertStyle = .warning
//        alert.messageText = NSLocalizedString("accessibility_alert_message", comment: "")
//        alert.informativeText = NSLocalizedString("accessibility_alert_comment", comment: "")
//        alert.addButton(withTitle: NSLocalizedString("accessibility_alert_deny", comment: ""))
//        alert.addButton(withTitle: NSLocalizedString("accessibility_alert_open", comment: ""))
//        alert.icon = NSImage(named: "NSSecurity")
//        return alert
//    }
//    private var accessibilityAllowed: Bool { AXIsProcessTrustedWithOptions(nil) }
//    private let accessibilityURL = URL(
//        string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
//    )
    
    func onNewCopy(_ hook: @escaping OnNewCopyHook) {
        onNewCopyHooks.append(hook)
    }
    
    func startListening() {
        Timer.scheduledTimer(timeInterval: timerInterval,
                             target: self,
                             selector: #selector(checkForChangesInPasteboard),
                             userInfo: nil,
                             repeats: true)
    }
    
    func copy(_ string: String, updateChangeCount: Bool = false) {
        pasteboard.clearContents()
        pasteboard.setString(string, forType: .string)
        if updateChangeCount {
            lastCheckedChangeCount = pasteboard.changeCount
        }
        checkForChangesInPasteboard()
    }
    
    func clear() {
        pasteboard.clearContents()
    }
    
    @objc
    func checkForChangesInPasteboard() {
        guard pasteboard.changeCount != lastCheckedChangeCount else {
            return
        }
        lastCheckedChangeCount = pasteboard.changeCount
        
        guard let pasteboardItems = pasteboard.pasteboardItems else {
            return
        }
        
        onNewCopyHooks.forEach {
            $0(pasteboardItems)
        }
    }
    
//    private func showAccessibilityWindow() {
//        if accessibilityAlert.runModal() == NSApplication.ModalResponse.alertSecondButtonReturn {
//            if let url = accessibilityURL {
//                NSWorkspace.shared.open(url)
//            }
//        }
//    }
}
