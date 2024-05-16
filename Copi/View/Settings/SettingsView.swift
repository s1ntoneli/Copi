//
//  SettingsView.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/4/13.
//

import SwiftUI
import KeyboardShortcuts
import Defaults
import LaunchAtLogin
import AppUpdater
import AXSwift

struct SettingsView: View {
    
    @EnvironmentObject var appUpdater: AppUpdater

    @Default(.showQuickActions) var quickActions: Bool
    @Default(.isOn) var isOn: Bool
    @Default(.overrideShortcuts) var globalMode: Bool
    
    @Default(.isServicesPermitted) var isServicesPermitted: Bool
    @State private var isAccessibilityPermitted = false

    @State private var systemClipboardContent: NSPasteboardItem? = nil
    @State private var systemClipboardTypeSelection: String = ""
    @State private var copiClipboardContent: String? = nil
    
    var body: some View {
        ScrollView {
            Form {
                if !isAccessibilityPermitted || !isServicesPermitted {
                    permissions
                } else {
                    Section {
                        if isOn {
                            toolbar
                            shortcuts
                        }
                        secureClipboard
                        systemClipboard
                    } header: {
                        header
                        versionUpdate
                    } footer: {
                        others
                    }
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
            Text("Copi is")
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
    
    var permissions: some View {
        Section("Permission Granted Needed") {
            if !isAccessibilityPermitted {
                Section {
                    Label("Use accessibility permission to get the selection text", systemImage: "checkmark.circle.fill")
                    HStack {
                        Button {
                            AXSwift.checkIsProcessTrusted(prompt: true)
                        } label: {
                            Text("Open Accessibility Settings")
                        }
                        .controlSize(.regular)
                        
                        Button {
                            isAccessibilityPermitted = AXSwift.checkIsProcessTrusted()
                        } label: {
                            Text("Validate")
                                .foregroundStyle(Color.accentColor)
                        }
                        .controlSize(.large)
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity)
                } header: {
                    HStack {
                        Text("1/2: Accessibility")
//                        Spacer()
//                        Button {
//                            checkIsProcessTrusted(prompt: true)
//                        } label: {
//                            Text("Open Settings")
//                                .fontWeight(.regular)
//                        }
                    }
                }
            } else if !isServicesPermitted {
                Section {
                    VStack(alignment: .leading) {
                        Label("Safe Copy", systemImage: "checkmark.circle.fill")
                        Label("Safe Paste", systemImage: "checkmark.circle.fill")
                        Label("Process Selected Text", systemImage: "checkmark.circle.fill")
                    }
                    HStack {
                        Button {
                            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.keyboard?Text") {
                                NSWorkspace.shared.open(url)
                            }
                        } label: {
                            Text("Open Keyboards Settings")
                        }
                        .controlSize(.regular)
                        
                        Button {
                            isServicesPermitted = true
                        } label: {
                            Text("Done")
                                .foregroundStyle(Color.accentColor)
                        }
                        .controlSize(.large)
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity)
                } header: {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("2/2: Services")
                        }
                        Text("Open Settings -> Keyboard Shortcuts -> Services -> Text -> Enabled 'Safe Copy' 'Safe Paste' 'Process Selected Text'")
                            .font(.subheadline)
                        //                    Text("We use System Services to ensure the security of Copy. You need to ensure the following services are enabled:")
                        //                        .font(.subheadline)
                    }
                }
            }
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
        Section("Copi Clipboard (Safe)") {
            Text(copiClipboardContent ?? "Empty")
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
        isAccessibilityPermitted = AXSwift.checkIsProcessTrusted()
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
        copiClipboardContent = NSPasteboard.safeCopy.string()
    }
}

#Preview {
    SettingsView()
}
