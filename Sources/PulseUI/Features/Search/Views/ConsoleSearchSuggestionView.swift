// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Pulse
import CoreData
import Combine

@available(iOS 15, tvOS 15, *)
struct ConsoleSearchSuggestionView: View {
    let suggestion: ConsoleSearchSuggestion
    var isActionable = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if case .apply(let token) = suggestion.action {
                    switch token {
                    case .filter:
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(.blue)
                    case .term:
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.blue)
                    case .scope:
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.blue)
                    }
                } else {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(.secondary)
                }
                Text(suggestion.text)
                    .lineLimit(1)
                Spacer()
                if isActionable {
                    ShortcutTooltip(title: "Tab")
                }
            }
        }
    }
}

struct ShortcutTooltip: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.caption)
            .foregroundColor(.separator)
            .background(Rectangle().frame(width: 34, height: 28).foregroundColor(Color.separator.opacity(0.2)).cornerRadius(8))
    }
}
