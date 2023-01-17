// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Pulse

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct ConsoleSearchContentTypeCell: View {
    @Binding var selection: ConsoleSearchCriteria.ContentType.ContentType

    var body: some View {
        Picker("Content Type", selection: $selection) {
            Section {
                Text("Any").tag(ContentType.any)
                Text("JSON").tag(ContentType.json)
                Text("Text").tag(ContentType.plain)
            }
            Section {
                Text("HTML").tag(ContentType.html)
                Text("CSS").tag(ContentType.css)
                Text("CSV").tag(ContentType.csv)
                Text("JS").tag(ContentType.javascript)
                Text("XML").tag(ContentType.xml)
                Text("PDF").tag(ContentType.pdf)
            }
            Section {
                Text("Image").tag(ContentType.anyImage)
                Text("JPEG").tag(ContentType.jpeg)
                Text("PNG").tag(ContentType.png)
                Text("GIF").tag(ContentType.gif)
                Text("WebP").tag(ContentType.webp)
            }
            Section {
                Text("Video").tag(ContentType.anyVideo)
            }
        }
    }

    private typealias ContentType = ConsoleSearchCriteria.ContentType.ContentType
}
