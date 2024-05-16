//
//  SwitchListView.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/4/1.
//

import SwiftUI

struct SwitchListView: View {
    @EnvironmentObject var vm: SwitchListVM
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(vm.items, id: \.name) { item in
                    SwitchItem(label: item.name, systemImage: item.systemImage ?? "info.square", storageKey: item.name)
                }
            }
            .padding()
        }
        .frame(maxHeight: 500)
    }
}

#Preview {
    SwitchListView()
}
