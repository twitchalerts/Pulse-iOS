// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Pulse


@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct ConsoleSearchResponseSourceCell: View {
    @Binding var selection: ConsoleSearchCriteria.Networking.Source

    var body: some View {
        Picker("Response Source", selection: $selection) {
            ForEach(ConsoleSearchCriteria.Networking.Source.allCases, id: \.self) {
                Text($0.title).tag($0)
            }
        }
    }
}
