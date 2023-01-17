// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Pulse


@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct ConsoleSearchPinsCell: View {
    @Binding var selection: ConsoleSearchCriteria.General
    let removeAll: () -> Void

    var body: some View {
#if os(macOS)
        HStack {
            ConsoleSearchToggleCell(title: "Only Pinned", isOn: $selection.inOnlyPins)
            Spacer()
            Button.destructive(action: removeAll) {
                Text("Remove Pins")
            }
        }
#else
        ConsoleSearchToggleCell(title: "Only Pinned", isOn: $selection.inOnlyPins)
        Button.destructive(action: removeAll) {
            Text("Remove Pins")
        }
#endif
    }
}
