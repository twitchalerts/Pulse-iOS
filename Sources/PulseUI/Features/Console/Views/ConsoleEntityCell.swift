// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import Foundation
import SwiftUI
import Pulse
import CoreData

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct ConsoleEntityCell: View {
    let entity: NSManagedObject

    var body: some View {
        if let task = entity as? NetworkTaskEntity {
            _ConsoleTaskCell(task: task)
        } else if let message = entity as? LoggerMessageEntity {
            if let task = message.task {
                _ConsoleTaskCell(task: task)
            } else {
                _ConsoleMessageCell(message: message)
            }
        } else {
            fatalError("Unsupported entity: \(entity)")
        }
    }

    @ViewBuilder
    static func make(for entity: NSManagedObject) -> some View {
        if let task = entity as? NetworkTaskEntity {
            _ConsoleTaskCell(task: task)
        } else if let message = entity as? LoggerMessageEntity {
            if let task = message.task {
                _ConsoleTaskCell(task: task)
            }
            else if let chart = message.chart {
                _ConsoleChartCell(chart: chart)
            }
            else {
                _ConsoleMessageCell(message: message)
            }
        } else {
            fatalError("Unsupported entity: \(entity)")
        }
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct _ConsoleMessageCell: View {
    let message: LoggerMessageEntity
    @State private var shareItems: ShareItems?

    var body: some View {
#if os(iOS)
        let cell = ConsoleMessageCell(viewModel: .init(message: message), isDisclosureNeeded: true)
            .background(NavigationLink("", destination: LazyConsoleDetailsView(message: message)).opacity(0))
#else
        // `id` is a workaround for macOS (needs to be fixed)
        let cell = NavigationLink(destination: LazyConsoleDetailsView(message: message).id(message.objectID)) {
            ConsoleMessageCell(viewModel: .init(message: message))
        }
#endif

#if os(iOS)
        if #available(iOS 15, *) {
            cell.swipeActions(edge: .leading, allowsFullSwipe: true) {
                PinButton(viewModel: .init(message)).tint(.pink)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(action: { shareItems = ShareService.share(message, as: .html) }) {
                    Label("Share", systemImage: "square.and.arrow.up.fill")
                }.tint(.blue)
            }
            .backport.contextMenu(menuItems: {
                Section {
                    Button(action: { shareItems = ShareService.share(message, as: .html) }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }.tint(.blue)
                    Button(action: { UXPasteboard.general.string = message.text }) {
                        Label("Copy Message", systemImage: "doc.on.doc")
                    }.tint(.blue)
                }
                Section {
                    PinButton(viewModel: .init(message)).tint(.pink)
                }
            }, preview: {
                ConsoleMessageCellPreview(message: message)
                    .frame(idealWidth: 320, maxHeight: 600)
            })
            .sheet(item: $shareItems, content: ShareView.init)
        } else {
            cell
        }
#else
        cell
#endif
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct _ConsoleTaskCell: View {
    let task: NetworkTaskEntity
    @State private var shareItems: ShareItems?

    var body: some View {
#if os(iOS)
        let cell = ConsoleTaskCell(task: task, isDisclosureNeeded: true)
            .background(NavigationLink("", destination: LazyNetworkInspectorView(task: task).id(task.objectID)).opacity(0))
#else
        let cell = NavigationLink(destination: LazyNetworkInspectorView(task: task).id(task.objectID)) {
            ConsoleTaskCell(task: task)
        }
#endif

#if os(iOS)
        if #available(iOS 15, *) {
            cell.swipeActions(edge: .leading, allowsFullSwipe: true) {
                PinButton(viewModel: .init(task)).tint(.pink)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(action: { shareItems = ShareService.share(task, as: .html) }) {
                    Label("Share", systemImage: "square.and.arrow.up.fill")
                }.tint(.blue)
            }
            .backport.contextMenu(menuItems: {
                Menu(content: {
                    AttributedStringShareMenu(shareItems: $shareItems) {
                        TextRenderer(options: .sharing).make { $0.render(task, content: .sharing) }
                    }
                    Button(action: { shareItems = ShareItems([task.cURLDescription()]) }) {
                        Label("Share as cURL", systemImage: "square.and.arrow.up")
                    }
                }, label: {
                    Label("Share...", systemImage: "square.and.arrow.up")
                })
                NetworkMessageContextMenu(task: task, sharedItems: $shareItems)
            }, preview: {
                ConsoleTaskCellPreview(task: task)
                    .frame(idealWidth: 320, maxHeight: 600)
            })
            .sheet(item: $shareItems, content: ShareView.init)
        } else {
            cell
        }
#else
        cell
#endif
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct _ConsoleChartCell: View {
    let chart: ChartEntity
    @State private var shareItems: ShareItems?
    
    var body: some View {
#if os(iOS)
        let cell = ConsoleChartCell(viewModel: .init(chartInfo: chart))
            .background(NavigationLink("", destination: LazyChartDetailsView(chart: chart)).opacity(0))
#else
        // `id` is a workaround for macOS (needs to be fixed)
        let cell = NavigationLink(destination: LazyChartDetailsView(chart: chart).id(chart.objectID)) {
            ConsoleChartCell(viewModel: .init(chartInfo: chart))
        }
#endif
        cell
    }
}

#if os(iOS)
@available(iOS 15, tvOS 15, *)
private struct ConsoleMessageCellPreview: View {
    let message: LoggerMessageEntity

    var body: some View {
        TextViewPreview(string: TextRenderer(options: .sharing).make {
            $0.render(message)
        })
    }
}

@available(iOS 15, tvOS 15, *)
private struct ConsoleTaskCellPreview: View {
    let task: NetworkTaskEntity

    var body: some View {
        TextViewPreview(string: TextRenderer(options: .sharing).make {
            $0.render(task, content: .preview)
        })
    }
}

@available(iOS 15, tvOS 15, *)
private struct TextViewPreview: View {
    let string: NSAttributedString

    var body: some View {
        let range = NSRange(location: 0, length: min(2000, string.length))
        let attributedString = try? AttributedString(string.attributedSubstring(from: range), including: \.uiKit)
            Text(attributedString ?? AttributedString("–"))
            .padding(12)
    }
}
#endif

// Create the underlying ViewModel lazily.
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct LazyNetworkInspectorView: View {
    let task: NetworkTaskEntity

    var body: some View {
        NetworkInspectorView(viewModel: .init(task: task))
    }
}

// Create the underlying ViewModel lazily.
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct LazyConsoleDetailsView: View {
    let message: LoggerMessageEntity

    var body: some View {
        ConsoleMessageDetailsView(viewModel: .init(message: message))
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct LazyChartDetailsView: View {
    let chart: ChartEntity

    var body: some View {
        if #available(iOS 16.0, tvOS 16.0, macOS 13.0, watchOS 9.0, *) {
            ConsoleChartDetailsView(chart: chart)
        } else {
            Text("macOS 13 is required")
        }
    }
}
