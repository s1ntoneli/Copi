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
//                    NSApp.setActivationPolicy(.accessory)
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
        Clipboard.shared.startListening()
        
        GlobalMode.shared.initialize()
        ManualMode.shared.initialize()
        WhiteListMode.shared.initialize()
    }
}
