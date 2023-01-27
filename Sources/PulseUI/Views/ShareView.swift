// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import SwiftUI

#if os(iOS)
import UIKit

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct ShareView: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]?
    private let cleanup: () -> Void
    private var completion: (() -> Void)?

    init(activityItems: [Any]) {
        self.activityItems = activityItems
        self.cleanup = {}
    }

    init(_ items: ShareItems) {
        self.activityItems = items.items
        self.cleanup = items.cleanup
    }

    func onCompletion(_ completion: @escaping () -> Void) -> Self {
        var copy = self
        copy.completion = completion
        return copy
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareView>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        controller.completionWithItemsHandler = { _, _, _, _ in
            cleanup()
            completion?()
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ShareView>) {
    }
}
#endif

#if os(macOS)
import AppKit

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct ShareView: View {
    let items: ShareItems

    private var cleanup: (() -> Void)?
    private var completion: (() -> Void)?

    init(_ items: ShareItems) {
        self.items = items
        self.cleanup = items.cleanup
    }

    func onCompletion(_ completion: @escaping () -> Void) -> Self {
        var copy = self
        copy.completion = completion
        return copy
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(NSSharingService.sharingServices(forItems: items.items), id: \.title) { item in
                Button(action: { item.perform(withItems: items.items) }) {
                    HStack {
                        Image(nsImage: item.image)
                        Text(item.title)
                    }
                }.buttonStyle(.plain)
            }
        }.padding(8)
    }
}

#endif
