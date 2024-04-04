//
//  Selection.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/4/3.
//

import Foundation
import SwiftUI

// selection key
struct SelectionKey: EnvironmentKey {
    static var defaultValue: [any Hashable] = []
}

extension EnvironmentValues {
    var selections: [any Hashable] {
        get { self[SelectionKey.self] }
        set { self[SelectionKey.self] = newValue }
    }
}

extension View {
    func selection<V>(selections: Set<V>) -> some View where V: Hashable {
        environment(\.selections, selections.map({ $0 }))
    }
}

// selection tag
struct SelectionTag<SelectionKey: Hashable>: ViewModifier {
    @Environment(\.selections) var selections

    var tag: SelectionKey

    func body(content: Content) -> some View {
        let selected = selections.contains(where: { $0 as! SelectionKey == tag })
        content
            .background(
                RoundedRectangle(cornerRadius: 0)
                    .fill(selected ? Color.accentColor : .clear)
            )
            .foregroundColor(selected ? .white : .primary)
    }
}

extension View {
    func stag<V>(_ tag: V) -> some View where V : Hashable {
        modifier(SelectionTag(tag: tag))
    }
}
