// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Pulse


@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct ConsoleSearchToggleCell: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
#if os(macOS)
        HStack {
            Toggle(title, isOn: $isOn)
            Spacer()
        }
#else
        Toggle(title, isOn: $isOn)
#endif
    }
}
