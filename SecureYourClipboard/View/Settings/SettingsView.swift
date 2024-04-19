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
    @Default(.manualMode) var manualMode: Bool
    @Default(.globalMode) var globalMode: Bool
    
    @State var conflictState = ""
    @State var safeCopyConflicts = 0
    @State var safePasteConflicts = 0

    var body: some View {
        Form {
            Section {
                Toggle("Global Mode", isOn: $globalMode)
                Text("Global Mode will proxy all the text copied into the system clipboard")
            }
            Section {
                Toggle("Manual Mode", isOn: $manualMode)
                Text("Manual Mode provide a new clipboard to copy and paste")
                Toggle("Show Quick Action", isOn: $quickActions)
                    .disabled(!manualMode)
                KeyboardShortcuts.Recorder("Safe Copy", name: .safeCopy, onConflict: { _, _ in
                    safeCopyConflicts += 1
                })
                .disabled(!manualMode)
//                .changeEffect(.shake(rate: .fast), value: safeCopyConflicts)
                KeyboardShortcuts.Recorder("Safe Paste", name: .safePaste, onConflict: { _, _ in
                    safePasteConflicts += 1
                })
                .disabled(!manualMode)
//                .changeEffect(.shake(rate: .fast), value: safePasteConflicts)
            }
        }
        .formStyle(.grouped)
        .controlSize(.mini)
    }
}

#Preview {
    SettingsView()
}
