//
//  PopupWindowController.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/4/2.
//

import Foundation
import SwiftUI

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
    
    func showWindowAt(_ location: NSPoint, _ text: String) {
        guard let window = window else { return }
        window.makeKeyAndOrderFront(nil)
        window.setFrameOrigin(location)
        viewModel.selectedText = text
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
    @Published var selectedText: String? = nil
}

struct PopupView: View {
    @EnvironmentObject var vm: PopupViewModel
    @State var hovered = false
    
    var body: some View {
        HStack {
            Text("Safe Copy")
                .background(hovered ? .blue : .clear)
                .foregroundColor(hovered ? .white : .primary)
                .onTapGesture {
                    NSPasteboard.general.safeCopyPlainTextValue = vm.selectedText
                    PopupWindowController.shared.closeWindow()
                }
                .onHover { hover in
                    hovered = hover
                }
            if let text = NSPasteboard.general.safeCopyPlainTextValue {
                Text("Safe Paste")
                    .background(hovered ? .blue : .clear)
                    .foregroundColor(hovered ? .white : .primary)
                    .onTapGesture {
                        PopupWindowController.shared.closeWindow()
                        pastePrivacy(text)
                    }
                    .onHover { hover in
                        hovered = hover
                    }
            }
        }
        .frame(width: 60, height: 32)
        .background(.white.opacity(0.5))
        .background(.regularMaterial)
        .cornerRadius(8)
    }
}

