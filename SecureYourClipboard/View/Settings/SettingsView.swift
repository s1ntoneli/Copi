//
//  SettingsView.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/4/13.
//

import SwiftUI
import KeyboardShortcuts
import Defaults
import Pow
import LaunchAtLogin
import AppUpdater

struct SettingsView: View {
    
    @EnvironmentObject var appUpdater: AppUpdater

    @Default(.showQuickActions) var quickActions: Bool
    @Default(.isOn) var isOn: Bool
    @Default(.overrideShortcuts) var globalMode: Bool
    
    @State private var systemClipboardContent: NSPasteboardItem? = nil
    @State private var systemClipboardTypeSelection: String = ""
    @State private var secureClipboardContent: String? = nil
    
    var body: some View {
        ScrollView {
            Form {
                Section {
                    if isOn {
                        toolbar
                        shortcuts
                        secureClipboard
                    }
                    systemClipboard
//                    Button {
//                        appUpdater.check()
//                    } label: {
//                        Text("check")
//                    }
                } header: {
                    header
                    versionUpdate
                } footer: {
                    others
                }
            }
            .formStyle(.grouped)
            .controlSize(.mini)
            .frame(width: 300)
            .animation(.default, value: isOn)
        }
        .task {
            onStart()
        }
        .fixedSize()
    }
    
    // MARK: - Views
    var header: some View {
        HStack {
            Text("SecureClipX is")
            Spacer()
            Toggle(isOn ? "On" : "Off", isOn: $isOn)
                .toggleStyle(.button)
                .controlSize(.regular)
        }
        .font(.headline)
    }
    
    var versionUpdate: some View {
        HStack {
            if let downloaded = appUpdater.downloadedAppBundle {
                Text("New Version Available")
                Spacer()
                Button {
                    appUpdater.install()
                } label: {
                    Text("Update Now")
                }
                .buttonStyle(BorderedProminentButtonStyle())
            }
        }
    }
    
    var toolbar: some View {
        Section("Action Bar") {
            Toggle("Show Action Bar on Selection", isOn: $quickActions)
                .disabled(!isOn)
        }
    }
    
    var shortcuts: some View {
        Section("Shortcuts") {
            Toggle("Override ⌘C/⌘V", isOn: $globalMode)
            KeyboardShortcuts.Recorder("Safe Copy", name: .safeCopy, onConflict: { _, _ in
            })
            .disabled(!isOn || globalMode)
            KeyboardShortcuts.Recorder("Safe Paste", name: .safePaste, onConflict: { _, _ in
            })
            .disabled(!isOn || globalMode)
        }
    }
    
    var secureClipboard: some View {
        Section("Secure Clipboard (Safe)") {
            Text(secureClipboardContent ?? "nil")
        }
    }
    
    // 系统剪贴板内容
    var systemClipboard: some View {
        Section {
            if let item = systemClipboardContent {
                VStack(alignment: .leading) {
                    ScrollView(.horizontal) {
                        Picker("", selection: $systemClipboardTypeSelection) {
                            ForEach(item.types, id: \.rawValue) { type in
                                Text(type.rawValue.prefix(12))
                                    .tag(type.rawValue)
                            }
                        }.pickerStyle(.segmented)
                            .fixedSize()
                    }
                    .scrollIndicators(.never)
                    let selection = systemClipboardTypeSelection
                    if !selection.isEmpty {
                        if selection == NSPasteboard.PasteboardType.string.rawValue {
                            Text(item.string(forType: .string) ?? "")
                                .lineLimit(5)
                        } else {
                            Text("\(item.data(forType: .init(selection))?.count ?? 0) Bytes")
                                .lineLimit(5)
                        }
                    }
                }
            } else {
                Text("Empty")
            }
        } header: {
            HStack {
                Text("System Clipboard (Unsafe)")
                Button {
                    NSPasteboard.general.clearContents()
                } label: {
                    Text("Clear")
                }
            }
        }
    }
    
    // other settings
    var others: some View {
        LaunchAtLogin.Toggle()
            .controlSize(.regular)
    }
    
    // MARK: - Methods
    func onStart() {
        updateSystemPasteboardItem(NSPasteboard.general.pasteboardItems ?? [])
        updateSecurePasteboard()
        
        NSPasteboard.general.onNewCopy { items in
            updateSystemPasteboardItem(items)
        }
        NSPasteboard.safeCopy.onNewCopy { items in
            updateSecurePasteboard()
        }
    }
    
    func updateSystemPasteboardItem(_ items: [NSPasteboardItem]) {
        systemClipboardContent = items.first
        systemClipboardTypeSelection = systemClipboardContent?.types.first?.rawValue ?? ""
    }
    
    func updateSecurePasteboard() {
        secureClipboardContent = NSPasteboard.safeCopy.string()
    }
}

#Preview {
    SettingsView()
}
