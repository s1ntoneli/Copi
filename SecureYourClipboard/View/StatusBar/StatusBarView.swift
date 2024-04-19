//
//  StatusBarView.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/4/12.
//

import SwiftUI

struct StatusBarView: View {
    @AppStorage("globalMode") var globalMode: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            Toggle("Global Mode", isOn: $globalMode)
            
        }
    }
}

#Preview {
    StatusBarView()
}
