//
//  PopupWindowController.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/4/2.
//

import Foundation
import SwiftUI
import AXSwift

class PopupWindowController: NSWindowController, NSWindowDelegate {
    static let shared = PopupWindowController()
    
    var contentView: PopupView!
    var isVisible: Bool {
        window?.isVisible ?? false
    }
    var viewModel = PopupViewModel()
    
    convenience init() {
        self.init(windowNibName: "PopupWindow")
        contentView = PopupView()
    }
    
    override func loadWindow() {
        window = PopupWindow(contentRect: .zero, styleMask: [.nonactivatingPanel], backing: .buffered, defer: true)
        window?.level = .mainMenu
        window?.center()
        window?.contentView = NSHostingView(rootView: contentView.environmentObject(viewModel))
        window?.delegate = self
        window?.hasShadow = true
        window?.backgroundColor = .clear
    }
    
    func showWindowAt(_ mouseLocation: NSPoint, _ text: String) {
        guard let window = window else { return }
        window.makeKeyAndOrderFront(nil)

        let location = NSPoint(x: mouseLocation.x - window.frame.width / 2, y: mouseLocation.y + window.frame.height / 2)
        window.setFrameOrigin(location)
        showWindow(nil)
    }
    
    func showWindowAt(_ mouseLocation: NSPoint, copyItem: UIElement?, pasteItem: UIElement?) {
        guard let window = window else { return }
        window.makeKeyAndOrderFront(nil)

        let location = NSPoint(x: mouseLocation.x - window.frame.width / 2, y: mouseLocation.y + window.frame.height / 2)
        window.setFrameOrigin(location)
        viewModel.copyItem = copyItem
        viewModel.pasteItem = pasteItem
        showWindow(nil)
    }
    
    func closeWindow() {
        close()
        window?.close()
    }
    
    func windowDidResignKey(_ notification: Notification) {
        closeWindow()
    }
}

class PopupWindow: NSPanel {
    override var canBecomeKey: Bool { false }
}

class PopupViewModel: ObservableObject {
    @Published var copyItem: UIElement?
    @Published var pasteItem: UIElement?
}

struct PopupView: View {
    @EnvironmentObject var vm: PopupViewModel
    @State var hovered = false
    @State var selections: Set<Int> = []
    
    var body: some View {
        HStack(spacing: 0) {
            if let copyItem = vm.copyItem {
                PopupItemView(title: "Copy", icon: "lock.shield")
                    .stag(0)
                    .onTapGesture {
                        try? copyItem.performAction(.press)
                        PopupWindowController.shared.closeWindow()
                    }
                    .onHover { hover in
                        if hover {
                            selections = [0]
                        }
                    }
            }
            if let text = NSPasteboard.safeCopy.string(), let pasteItem = vm.pasteItem {
                PopupItemView(title: "Paste", icon: "lock.shield")
                    .onTapGesture {
                        PopupWindowController.shared.closeWindow()
                        try? pasteItem.performAction(.press)
                    }
                    .stag(1)
                    .onHover { hover in
                        if hover {
                            selections = [1]
                        }
                    }
            }
        }
        .fixedSize()
        .background(.white.opacity(0.9))
        .cornerRadius(4)
        .selection(selections: selections)
        .onHover { hover in
            selections = []
        }
    }
}

struct PopupItemView: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            Image(systemName: icon)
            Text(title)
        }
        .padding(6)
    }
}
