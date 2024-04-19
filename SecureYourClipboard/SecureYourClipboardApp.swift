//
//  SecureYourClipboardApp.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/3/25.
//

import SwiftUI
import KeyboardShortcuts
import Defaults

@main
struct SecureYourClipboardApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    
    let persistenceController = PersistenceController.shared
    @StateObject var switchListVM: SwitchListVM = SwitchListVM()

    var body: some Scene {
        WindowGroup {
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            EmptyView()
                .frame(width: 0, height: 0)
                .onAppear(perform: {
                    NSApp.setActivationPolicy(.accessory)
                })
        }
        .windowResizability(.contentSize)

        MenuBarExtra("App", systemImage: "square.stack.3d.down.forward") {
//            StatusBarView()
            SettingsView()
        }
        .menuBarExtraStyle(.window)
        .windowResizability(.contentSize)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("applicationDidFinishLaunching")
        KeyboardShortcuts.onKeyUp(for: .safeCopy) { [self] in
            NSPasteboard.general.safeCopyPlainTextValue = NSPasteboard.general.selectedTextValue
            print("safe copy", NSPasteboard.general.safeCopyPlainTextValue)
        }
        KeyboardShortcuts.onKeyUp(for: .safePaste) { [self] in
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
            print("servicesMenu", NSApp.servicesMenu?.items.count)
            
//            NSApplication.shared.servicesMenu?.items.forEach({ item in
//                print("item \(item.title)")
//            })
            let item = NSApp.servicesMenu?.items.first(where: { $0.title == "Test Process Text2" })
            print("enable", item?.isEnabled, item?.isAlternate, item?.isHidden, item?.representedObject)
        }
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
//                    Clipboard.shared.onNewCopy { newItem in
//                        interceptCopy(newItem, filters: switchListVM.allEnablesItems)
//                    }
        Clipboard.shared.startListening()
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
        
        let eventMask = (1 << CGEventType.keyDown.rawValue)

        // 创建一个事件监听器，并指定位置为cghidEventTap
        let eventTap1 = CGEvent.tapCreate(tap: .cgAnnotatedSessionEventTap,
                                          place: .headInsertEventTap,
                                          options: .defaultTap,
                                          eventsOfInterest: CGEventMask(eventMask),
                                          callback: { (proxy, type, event, refcon) in
            print("first", event.flags.contains(.maskCommand), event.getIntegerValueField(.keyboardEventKeycode))
            if UserDefaults.standard.bool(forKey: "globalMode") && event.flags.contains(.maskCommand) && event.getIntegerValueField(.keyboardEventKeycode) == 9 {
                    //                            pastePrivacy("")
                if !NSPasteboard.general.pasteboardItems!.isEmpty || NSPasteboard.general.safeCopyValue == nil {
                    return Unmanaged.passRetained(event)
                }

                NSPasteboard.general.onPrivateMode {
//                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.writeObjects(NSPasteboard.general.safeCopyValue ?? [])
                    callSystemPaste()
                    NSPasteboard.general.safeCopyValue = NSPasteboard.general.safeCopyValue.copy()
                }
                return nil
            }
            // 处理事件的回调函数
            return Unmanaged.passRetained(event)
        }, userInfo: nil)
        // 启用事件监听器
        if let eventTap = eventTap1 {
            let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
            CFRunLoopRun()
        }
//        runService()
        NSApp.servicesProvider = self
        NSUpdateDynamicServices()
    }
    
//    @objc func processSelectedText(pboard: NSPasteboard, userData: String, error: AutoreleasingUnsafeMutablePointer<NSString?>) {
//        if let selectedText = pboard.string(forType: .string) {
//            // 在这里处理选中的文本
//            print("Selected Text: \(selectedText)")
//        }
//    }
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
}
