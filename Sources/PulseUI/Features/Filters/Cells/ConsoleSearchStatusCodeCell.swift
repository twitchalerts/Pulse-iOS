// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Pulse


@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct ConsoleSearchStatusCodeCell: View {
    @Binding var selection: ValuesRange<String>

    var body: some View {
        HStack {
            Text("Status Code")
            Spacer()
            RangePicker(range: $selection)
        }
    }
}
