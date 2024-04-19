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

struct SettingsView: View {

    @Default(.showQuickActions) var quickActions: Bool
    @Default(.globalMode) var globalMode: Bool
    
    @State var conflictState = ""
    @State var safeCopyConflicts = 0
    @State var safePasteConflicts = 0

    var body: some View {
        Form {
            Section("Global Mode") {
                Text("Global Mode will proxy all the string with the second clipboard")
                Toggle("Enabled", isOn: $globalMode)
            }
            Section("The Second Clipboard") {
                Toggle("Show Quick Action", isOn: $quickActions)
                KeyboardShortcuts.Recorder("Safe Copy", name: .safeCopy, onConflict: { _, _ in
                    safeCopyConflicts += 1
                })
                .changeEffect(.shake(rate: .fast), value: safeCopyConflicts)
                KeyboardShortcuts.Recorder("Safe Paste", name: .safePaste, onConflict: { _, _ in
                    safePasteConflicts += 1
                })
                .changeEffect(.shake(rate: .fast), value: safePasteConflicts)
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    SettingsView()
}
