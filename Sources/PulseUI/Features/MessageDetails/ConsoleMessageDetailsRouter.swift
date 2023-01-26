// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import CoreData
import Pulse


@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct ConsoleMessageDetailsRouter: View {
    @ObservedObject var viewModel: ConsoleDetailsRouterViewModel

    var body: some View {
        if let viewModel = viewModel.viewModel {
            switch viewModel {
            case .message(let viewModel):
                ConsoleMessageDetailsView(viewModel: viewModel)
                    .id(self.viewModel.id)
            case .task(let viewModel):
                // TODO: rework the inspector to not require id workaround
                NetworkInspectorView(viewModel: viewModel)
                    .id(self.viewModel.id)
            case .chart(let viewModel):
                if #available(macOS 13.0, *) {
                    ConsoleChartDetailsView(viewModel: viewModel)
                            .id(self.viewModel.id)
                }
                else {
                    Text("Chart info is available from macOS 13")
                }
            }
        }
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
final class ConsoleDetailsRouterViewModel: ObservableObject {
    @Published private(set) var viewModel: DetailsViewModel?
    var id: NSManagedObjectID?

    private let store: LoggerStore

    init(store: LoggerStore) {
        self.store = store
    }

    func select(_ entity: NSManagedObject?) {
        self.id = entity?.objectID
        if let message = entity as? LoggerMessageEntity {
            if let task = message.task {
                viewModel = .task(.init(task: task))
            }
            else if let chart = message.chart {
                viewModel = .chart(.init(store: store, chartInfo: chart))
            }
            else {
                viewModel = .message(.init(message: message))
            }
        } else if let task = entity as? NetworkTaskEntity {
            viewModel = .task(.init(task: task))
        } else {
            viewModel = nil
        }
    }

    enum DetailsViewModel {
        case message(ConsoleMessageDetailsViewModel)
        case task(NetworkInspectorViewModel)
        case chart(ConsoleChartDetailsViewModel)
    }
}
