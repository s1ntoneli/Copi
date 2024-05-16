//
//  SwitchListVM.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/4/1.
//

import Foundation

class SwitchListVM: ObservableObject {
    @Published var items: [SensitiveDataRegexModel] = []
    
    var allEnablesItems: [SensitiveDataRegexModel] {
        items.filter { $0.isEnabled }
    }
    
    init() {
        load()
    }

    func load() {
        Task { @MainActor in
            items = await SwitchItemProvider.loadFromAssets()
        }
    }
}
