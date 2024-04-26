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

@main
struct SecureYourClipboardApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    
    let persistenceController = PersistenceController.shared
    @StateObject var switchListVM: SwitchListVM = SwitchListVM()
    @StateObject var appUpdater = AppUpdaterGithub(owner: "s1ntoneli", repo: "SecureClip", interval: 60 * 60)

    var body: some Scene {
        WindowGroup {
            EmptyView()
                .frame(width: 0, height: 0)
                .onAppear(perform: {
//                    NSApp.setActivationPolicy(.accessory)
                })
                .task {
                    appUpdater.check()
                }
        }
        .windowResizability(.contentSize)

        MenuBarExtra("App", systemImage: "square.stack.3d.down.forward") {
            SettingsView()
                .environmentObject(appUpdater)
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
