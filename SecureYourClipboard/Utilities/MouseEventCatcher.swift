//
//  MouseEventCatcher.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/4/2.
//

import Foundation
import AppKit

class MouseEventCatcher {
    
    static let shared = MouseEventCatcher()
    
    typealias OnSelectEvent = (NSEvent) -> Void
    typealias OnUnSelectEvent = (NSEvent) -> Void
    
    var onSelectEventHooks: [OnSelectEvent] = []
    var onUnSelectEventHooks: [OnUnSelectEvent] = []

    var eventMonitor: Any? = nil
    var downMonitor: Any? = nil
    var dragMonitor: Any? = nil
    var scrollWheelMonitor: Any? = nil
    
    init() {
        // 拖拽判断
        var downLocation: NSPoint = .zero
        // 长按判断
        var downTimer: Timer? = nil
        // 双击判断
        var lastDownTime: Date? = nil
        var lastDownLocation: NSPoint? = nil
        var doubleClicked = false
        // 是否已经处理过
        var handled = false
        // 滑动取消
        var totalScrollDistance = 0.0

        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseUp], handler: { [self] event in
            print("onLeftMouseUp")
            if !handled {
                downTimer?.invalidate()
                downTimer = nil
                if event.locationInWindow.distance(downLocation) > 10 || doubleClicked {
                    notifyAllSelectHooks(event: event)
                } else {
                    notifyAllUnSelectHooks(event: event)
                }
            }
        })
        dragMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDragged], handler: { event in
            if event.locationInWindow.distance(downLocation) > 10 {
                downTimer?.invalidate()
                downTimer = nil
                self.notifyAllUnSelectHooks(event: event)
                handled = false
            }
        })
        scrollWheelMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.scrollWheel], handler: { event in
            totalScrollDistance += NSPoint(x: event.scrollingDeltaX, y: event.scrollingDeltaY).distance(.zero)
            if totalScrollDistance > 100 {
                self.notifyAllUnSelectHooks(event: event)
            }
        })
        downMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown, handler: { event in
            handled = false
            downLocation = event.locationInWindow
            totalScrollDistance = 0
            
            let current = Date.now
            if let lastDownTime, let lastDownLocation {
                if current.timeIntervalSince(lastDownTime) < 0.38 && event.locationInWindow.distance(lastDownLocation) <= 5 {
                    downTimer?.invalidate()
                    downTimer = nil
//                    downTimer = Timer.scheduledTimer(withTimeInterval: 0.38, repeats: false) { timer in
//                        handled = true
//                        self.notifyAllSelectHooks(event: event)
//                        downTimer = nil
//                    }
                    doubleClicked = true
                    return
                }
            }
            doubleClicked = false
            lastDownTime = current
            lastDownLocation = event.locationInWindow
            
            downTimer = Timer.scheduledTimer(withTimeInterval: 0.38, repeats: false) { timer in
                handled = true
                if event.locationInWindow.distance(downLocation) <= 10 {
                    self.notifyAllSelectHooks(event: event)
                }
                downTimer = nil
            }
        })
    }
    
    deinit {
        guard let eventMonitor else { return }
        NSEvent.removeMonitor(eventMonitor)
    }
    
    func onSelectEventHooks(_ hook: @escaping OnSelectEvent) {
        onSelectEventHooks.append(hook)
    }
    
    func onUnSelectEventHooks(_ hook: @escaping OnUnSelectEvent) {
        onUnSelectEventHooks.append(hook)
    }
    
    func notifyAllSelectHooks(event: NSEvent) {
        onSelectEventHooks.forEach { hook in
            hook(event)
        }
    }
    
    func notifyAllUnSelectHooks(event: NSEvent) {
        onUnSelectEventHooks.forEach { hook in
            hook(event)
        }
    }
}

extension NSPoint {
    func distance(_ point: NSPoint) -> Double {
        let deltaX = point.x - x
        let deltaY = point.y - y
        return sqrt(deltaX * deltaX + deltaY * deltaY)
    }
}
