//
//  SwitchItem.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/3/28.
//

import SwiftUI

struct SwitchItem: View {
    var label: String
    var systemImage: String
    @AppStorage private var isOnStorage: Bool
    
    init(label: String, systemImage: String, storageKey: String) {
        self.label = label
        self.systemImage = systemImage
        _isOnStorage = AppStorage(wrappedValue: true, storageKey)
    }
    
    var body: some View {
        Toggle(isOn: $isOnStorage) {
            Label(label, systemImage: systemImage)
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .toggleStyle(.switch)
    }
}

#Preview {
    SwitchItem(label: "Phone", systemImage: "phone", storageKey: "phone")
}
