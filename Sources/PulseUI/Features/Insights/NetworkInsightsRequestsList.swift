// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import CoreData
import Pulse
import Combine

#if os(iOS)


@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct NetworkInsightsRequestsList: View {
    @ObservedObject var viewModel: NetworkInsightsRequestsListViewModel

    public var body: some View {
        ConsoleTableView(
            header: { EmptyView() },
            viewModel: viewModel.table,
            detailsViewModel: viewModel.details
        )
    }
}
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
final class NetworkInsightsRequestsListViewModel: ObservableObject {
    let table: ConsoleTableViewModel
    let details: ConsoleDetailsRouterViewModel

    init(tasks: [NetworkTaskEntity]) {
        self.table = ConsoleTableViewModel(searchViewModel: nil)
        self.table.entities = tasks
        self.details = ConsoleDetailsRouterViewModel()
    }
}

#endif
