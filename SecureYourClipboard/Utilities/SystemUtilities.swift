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
        let eventSource = CGEventSource(stateID: .privateState)
        return [
            CGEvent(keyboardEventSource: eventSource, virtualKey: CGKeyCode(virtualKey), keyDown: true)!,
            CGEvent(keyboardEventSource: eventSource, virtualKey: CGKeyCode(virtualKey), keyDown: false)!,
        ]
    }
    
    let tapLocation = CGEventTapLocation.cgAnnotatedSessionEventTap
    let events = keyEvents(forPressAndReleaseVirtualKey: 9)
    
    events.forEach {
        $0.flags = .maskCommand
        $0.post(tap: tapLocation)
    }
}

func callSystemCopy() {
    func keyEvents(forPressAndReleaseVirtualKey virtualKey: Int) -> [CGEvent] {
        let eventSource = CGEventSource(stateID: .privateState)
        eventSource?.setLocalEventsFilterDuringSuppressionState([.permitLocalMouseEvents, .permitSystemDefinedEvents, .permitLocalKeyboardEvents], state: .numberOfEventSuppressionStates)
        return [
            CGEvent(keyboardEventSource: eventSource, virtualKey: CGKeyCode(virtualKey), keyDown: true)!,
            CGEvent(keyboardEventSource: eventSource, virtualKey: CGKeyCode(virtualKey), keyDown: false)!,
        ]
    }
    
    let tapLocation = CGEventTapLocation.cgAnnotatedSessionEventTap
    let events = keyEvents(forPressAndReleaseVirtualKey: 8)
    
    events.forEach {
        $0.flags = .maskCommand
//        $0.post(tap: tapLocation)
        $0.postToPid(NSWorkspace.shared.frontmostApplication?.processIdentifier ?? 0)
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
        set {
            objc_setAssociatedObject(self, &kArchiveKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
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
        self.archive = archive
    }

    func restore() {
        clearContents()
        writeObjects(archive ?? [])
    }
    
    func onPrivateMode(endDelay: TimeInterval = 0.05, _ task: @escaping () -> Void) {
        save()
        task()
        if endDelay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + endDelay) {
                NSPasteboard.general.restore()
                NSPasteboard.general.archive = nil
            }
        } else {
            NSPasteboard.general.restore()
            NSPasteboard.general.archive = nil
        }
    }
}

// safe copy value
private var kSafeCopyKey = 0
extension NSPasteboard {
    func safeCopy() {
        
    }
    var safeCopyValue: [NSPasteboardItem]? {
        get {
            objc_getAssociatedObject(self, &kSafeCopyKey) as? [NSPasteboardItem]
        }
        set {
            objc_setAssociatedObject(self, &kSafeCopyKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    func saveToSafeCopyValue() {
//        self.safeCopyValue = pasteboardItems.copy()
        self.safeCopyValue = pasteboardItems.copy()
    }
}

// clone
extension [NSPasteboardItem]? {
    func copy() -> [NSPasteboardItem] {
        var copyValue = [NSPasteboardItem]()

        for item in self ?? [] {
            let newItem = NSPasteboardItem()
            for type in item.types {
                if let data = item.data(forType: type) {
                    newItem.setData(data, forType: type)
                }
            }
            copyValue.append(newItem)
        }
        let fromSCX = NSPasteboardItem()
        fromSCX.setData(Data(), forType: .fromSecureClipX)
        copyValue.append(fromSCX)
        
        return copyValue
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

// safe copy plain text value
private var kSelectedTextKey = 0
extension NSPasteboard {
    var selectedTextValue: String? {
        get {
            objc_getAssociatedObject(self, &kSelectedTextKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &kSelectedTextKey, newValue, .OBJC_ASSOCIATION_RETAIN)
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

func listenAndInterceptKeyEvent() {
    let eventMask = (1 << CGEventType.keyDown.rawValue)
    
    // 创建一个事件监听器，并指定位置为 cghidEventTap
    guard let eventTap =
            CGEvent.tapCreate(tap: .cghidEventTap,
                              place: .headInsertEventTap,
                              options: .defaultTap,
                              eventsOfInterest: CGEventMask(eventMask),
                              callback: { (proxy, type, event, refcon) in
                // 处理事件的回调函数
                return Unmanaged.passRetained(event)
            }, userInfo: nil) else { return }
    
    let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
    CGEvent.tapEnable(tap: eventTap, enable: true)
    CFRunLoopRun()
}

extension NSPasteboard.PasteboardType {
    static var fromSecureClipX: NSPasteboard.PasteboardType = .init("com.gokoding.SecureYourClipboard")
}

func measureTime(block: () -> Void) {
    let startTime = DispatchTime.now()
    block()
    let endTime = DispatchTime.now()
    
    let nanoseconds = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
    let milliseconds = Double(nanoseconds) / 1_000_000
    
    print("Execution time: \(milliseconds) milliseconds")
}
