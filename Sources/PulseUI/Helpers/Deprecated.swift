// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import CoreData
import Pulse
import Combine
import SwiftUI

@available(*, deprecated, message: "PinsView view is no longer available. Please use ConsoleView instead.")
public struct PinsView: View {
    public var body: some View {
        EmptyView()
    }
}

#if !os(macOS) && !os(watchOS)
@available(*, deprecated, message: "Please use ConsoleView pre-configured with .network mode")
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public struct NetworkView: View {
    private let store: LoggerStore

    public init(store: LoggerStore) {
        self.store = store
    }

    public var body: some View {
        ConsoleView.network(store: store)
    }
}
#endif

@available(*, deprecated, message: "Please use ConsoleView directly instead")
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public struct MainView: View {
    let viewModel: ConsoleViewModel

    public init(store: LoggerStore = .shared, onDismiss: (() -> Void)? = nil) {
        self.viewModel = ConsoleViewModel(store: store)
        self.viewModel.onDismiss = onDismiss
    }

    public var body: some View {
#if os(macOS)
        ConsoleView(viewModel: viewModel)
#else
        NavigationView {
            if #available(iOS 14.0, *) {
                ConsoleView(viewModel: viewModel)
            }
        }.navigationViewStyle(.stack)
#endif
    }
}

#if DEBUG
@available(*, deprecated, message: "Deprecated")
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(store: .mock)
    }
}

#endif
