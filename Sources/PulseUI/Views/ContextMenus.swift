// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Pulse
import Combine

#if os(iOS) || os(macOS)

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct NetworkMessageContextMenu: View {
    let task: NetworkTaskEntity

    @Binding private(set) var sharedItems: ShareItems?

    var body: some View {
        NetworkMessageContextMenuCopySection(task: task)
        if let message = task.message {
            PinButton(viewModel: .init(message))
        }
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct NetworkMessageContextMenuCopySection: View {
    var task: NetworkTaskEntity

    var body: some View {
        Section {
            Menu(content: {
                if let url = task.url {
                    Button(action: {
                        UXPasteboard.general.string = url
                        runHapticFeedback()
                    }) {
                        Label("Copy URL", systemImage: "doc.on.doc")
                    }
                }
                if let host = task.host {
                    Button(action: {
                        UXPasteboard.general.string = host
                        runHapticFeedback()
                    }) {
                        Label("Copy Host", systemImage: "doc.on.doc")
                    }
                }
                if task.requestBodySize > 0 {
                    Button(action: {
                        guard let data = task.requestBody?.data else { return }
                        UXPasteboard.general.string = String(data: data, encoding: .utf8)
                        runHapticFeedback()
                    }) {
                        Label("Copy Request", systemImage:"arrow.up.circle")
                    }
                }
                if task.responseBodySize > 0 {
                    Button(action: {
                        guard let data = task.responseBody?.data else { return }
                        UXPasteboard.general.string = String(data: data, encoding: .utf8)
                        runHapticFeedback()
                    }) {
                        Label("Copy Response", systemImage: "arrow.down.circle")
                    }
                }
            }, label: {
                Label("Copy...", systemImage: "doc.on.doc")
            })
        }
    }
}
#endif

#if os(iOS) || os(macOS)
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct StringSearchOptionsMenu: View {
    @Binding private(set) var options: StringSearchOptions
    var isKindNeeded = true

#if os(macOS)
    var body: some View {
        Menu(content: { contents }, label: {
            Image(systemName: "ellipsis.circle")
        })
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
    }
#else
    var body: some View {
        contents
    }
#endif

    @ViewBuilder
    private var contents: some View {
        Picker("Kind", selection: $options.kind) {
            ForEach(StringSearchOptions.Kind.allCases, id: \.self) {
                Text($0.rawValue).tag($0)
            }
        }
        Picker("Case Sensitivity", selection: $options.caseSensitivity) {
            ForEach(StringSearchOptions.CaseSensitivity.allCases, id: \.self) {
                Text($0.rawValue).tag($0)
            }
        }
        if let rules = options.allEligibleMatchingRules(), isKindNeeded {
            Picker("Matching Rule", selection: $options.rule) {
                ForEach(rules, id: \.self) {
                    Text($0.rawValue).tag($0)
                }
            }
        }
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct AttributedStringShareMenu: View {
    @Binding var shareItems: ShareItems?
    let string: () -> NSAttributedString

    var body: some View {
        Button(action: { shareItems = ShareService.share(string(), as: .plainText) }) {
            Label("Share as Text", systemImage: "square.and.arrow.up")
        }
        Button(action: { shareItems = ShareService.share(string(), as: .html) }) {
            Label("Share as HTML", systemImage: "square.and.arrow.up")
        }
#if os(iOS)
        Button(action: { shareItems = ShareService.share(string(), as: .pdf) }) {
            Label("Share as PDF", systemImage: "square.and.arrow.up")
        }
#endif
    }
}

#if DEBUG
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct StringSearchOptionsMenu_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 32) {
            Spacer()
            Menu(content: {
                AttributedStringShareMenu(shareItems: .constant(nil)) {
                    TextRenderer(options: .sharing).make { $0.render(LoggerStore.preview.entity(for: .login), content: .sharing) }
                }
            }) {
                Text("Attributed String Share")
            }
            Menu(content: {
                Section(header: Label("Search Options", systemImage: "magnifyingglass")) {
                    StringSearchOptionsMenu(options: .constant(.default))
                }
            }) {
                Text("Search Options")
            }
        }
    }
}
#endif

#endif
