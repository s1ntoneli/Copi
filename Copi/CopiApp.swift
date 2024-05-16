//
//  SecureYourClipboardApp.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/3/25.
//

import SwiftUI
import KeyboardShortcuts
import Defaults
import AppUpdater
import AXSwift

@main
struct CopiApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    
    @StateObject var switchListVM: SwitchListVM = SwitchListVM()
    @StateObject var appUpdater = AppUpdater(owner: "s1ntoneli", repo: "Copi", interval: 60 * 60)

    var body: some Scene {
        WindowGroup {
            EmptyView()
                .frame(width: 0, height: 0)
                .onAppear(perform: {
//                    NSApp.setActivationPolicy(.accessory)
                    NSApp.setActivationPolicy(.prohibited)
                })
                .task {
                    appUpdater.check()
                }
        }
        .windowResizability(.contentSize)

        MenuBarExtra("App", systemImage: "square.stack.3d.down.forward") {
            SettingsView()
                .environmentObject(appUpdater)
                .onAppear {
                    NotificationCenter.default.addObserver(
                                forName: NSWindow.didChangeOcclusionStateNotification, object: nil, queue: nil)
                    { notification in
                        print("Visible: \((notification.object as! NSWindow).isVisible)", (notification.object as! NSWindow))
                        
                    }
                }
        }
        .menuBarExtraStyle(.window)
        .windowResizability(.contentSize)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("applicationDidFinishLaunching")
        NSPasteboard.general.startListening()
        NSPasteboard.safeCopy.startListening()
        
        GlobalMode.shared.initialize()
        ManualMode.shared.initialize()
        WhiteListMode.shared.initialize()
    }
}
