// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct InfoRow: View {
    let title: String
    let details: String?

    var body: some View {
        HStack {
            Text(title)
                .lineLimit(1)
            Spacer()
            if let details = details {
                Text(details)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
            }
        }
    }
}


@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct KeyValueRow: Identifiable {
    let id: Int
    let item: (String, String?)

    var title: String { item.0 }
    var details: String? { item.1 }
}
