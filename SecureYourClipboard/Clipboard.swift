//
//  Clipboard.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/3/25.
//

import Foundation
import AppKit

class Clipboard {
    static let shared = Clipboard()
    
    typealias OnNewCopyHook = ([NSPasteboardItem]) -> Void
    
    var onNewCopyHooks: [OnNewCopyHook] = []
    var changeCount: Int
    
    private let pasteboard = NSPasteboard.general
    private let timerInterval = 0.05
    
    private var accessibilityAlert: NSAlert {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = NSLocalizedString("accessibility_alert_message", comment: "")
        alert.informativeText = NSLocalizedString("accessibility_alert_comment", comment: "")
        alert.addButton(withTitle: NSLocalizedString("accessibility_alert_deny", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("accessibility_alert_open", comment: ""))
        alert.icon = NSImage(named: "NSSecurity")
        return alert
    }
    private var accessibilityAllowed: Bool { AXIsProcessTrustedWithOptions(nil) }
    private let accessibilityURL = URL(
        string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
    )
    
    init() {
        changeCount = pasteboard.changeCount
    }
    
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
            changeCount = pasteboard.changeCount
        }
        checkForChangesInPasteboard()
    }
    
    func clear() {
        pasteboard.clearContents()
    }
    
    @objc
    func checkForChangesInPasteboard() {
        guard pasteboard.changeCount != changeCount else {
            return
        }
        changeCount = pasteboard.changeCount
        
        guard let pasteboardItems = pasteboard.pasteboardItems else {
            return
        }
        
        onNewCopyHooks.forEach {
            $0(pasteboardItems)
        }
    }
    
    private func showAccessibilityWindow() {
        if accessibilityAlert.runModal() == NSApplication.ModalResponse.alertSecondButtonReturn {
            if let url = accessibilityURL {
                NSWorkspace.shared.open(url)
            }
        }
    }
}
