//
//  SystemUtilities.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/4/2.
//

import Foundation
import AppKit
import Carbon
import Cocoa

// 模拟粘贴
func pastePrivacy(_ text: String) {
    NSPasteboard.general.onPrivateMode {
        copyToClipboard(text)
        callSystemPaste()
    }
}

func callSystemPaste() {
    func keyEvents(forPressAndReleaseVirtualKey virtualKey: Int) -> [CGEvent] {
        let eventSource = CGEventSource(stateID: .hidSystemState)
        return [
            CGEvent(keyboardEventSource: eventSource, virtualKey: CGKeyCode(virtualKey), keyDown: true)!,
            CGEvent(keyboardEventSource: eventSource, virtualKey: CGKeyCode(virtualKey), keyDown: false)!,
        ]
    }
    
    let tapLocation = CGEventTapLocation.cghidEventTap
    let events = keyEvents(forPressAndReleaseVirtualKey: 9)
    
    events.forEach {
        $0.flags = .maskCommand
        $0.post(tap: tapLocation)
    }
}

func callSystemCopy() {
    func keyEvents(forPressAndReleaseVirtualKey virtualKey: Int) -> [CGEvent] {
        let eventSource = CGEventSource(stateID: .hidSystemState)
        return [
            CGEvent(keyboardEventSource: eventSource, virtualKey: CGKeyCode(virtualKey), keyDown: true)!,
            CGEvent(keyboardEventSource: eventSource, virtualKey: CGKeyCode(virtualKey), keyDown: false)!,
        ]
    }
    
    let tapLocation = CGEventTapLocation.cghidEventTap
    let events = keyEvents(forPressAndReleaseVirtualKey: 8)
    
    events.forEach {
        $0.flags = .maskCommand
        $0.post(tap: tapLocation)
    }
}

func copyToClipboard(_ text: String) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(text, forType: .string)
}

import ObjectiveC.runtime

private var kArchiveKey: UInt8 = 0

extension NSPasteboard {

    var archive: [NSPasteboardItem]? {
        get {
            return objc_getAssociatedObject(self, &kArchiveKey) as? [NSPasteboardItem]
        }
    }

    func setArchive(_ newArchive: [NSPasteboardItem]?) {
        objc_setAssociatedObject(self, &kArchiveKey, newArchive, .OBJC_ASSOCIATION_RETAIN)
    }

    func save() {
        var archive = [NSPasteboardItem]()
        for item in pasteboardItems! {
            let archivedItem = NSPasteboardItem()
            for type in item.types {
                if let data = item.data(forType: type) {
                    archivedItem.setData(data, forType: type)
                }
            }
            archive.append(archivedItem)
        }
        setArchive(archive)
    }

    func restore() {
        clearContents()
        writeObjects(archive ?? [])
    }
    
    func onPrivateMode(_ task: @escaping () -> Void) {
        save()
        task()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            NSPasteboard.general.restore()
        }
    }
}

// safe copy value
private var kSafeCopyKey = 0
extension NSPasteboard {
    var safeCopyValue: [NSPasteboardItem]? {
        get {
            objc_getAssociatedObject(self, &kSafeCopyKey) as? [NSPasteboardItem]
        }
        set {
            objc_setAssociatedObject(self, &kSafeCopyKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
// safe copy plain text value
private var kSafeCopyPlainTextKey = 0
extension NSPasteboard {
    var safeCopyPlainTextValue: String? {
        get {
            objc_getAssociatedObject(self, &kSafeCopyPlainTextKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &kSafeCopyPlainTextKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

func pollTask(every interval: TimeInterval, timeout: TimeInterval = 2, task: @escaping () -> Bool, timeoutCallback: @escaping () -> Void = {}) {
    var elapsedTime: TimeInterval = 0
    let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
        if task() {
            timer.invalidate()
        } else {
            elapsedTime += interval
            if elapsedTime >= timeout {
                timer.invalidate()
                timeoutCallback()
            } else {
                print("Still polling...")
            }
        }
    }
    
    RunLoop.current.run()
}
