// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Pulse


@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct NetworkRequestInfoCell: View {
    let viewModel: NetworkRequestInfoCellViewModel

    var body: some View {
        NavigationLink(destination: destinationRequestDetails) {
            contents
        }
    }

    private var contents: some View {
        (Text(viewModel.httpMethod).fontWeight(.semibold).font(.callout.smallCaps()) + Text(" ") + Text(viewModel.url))
            .lineLimit(4)
            .font(.callout)
    }

    private var destinationRequestDetails: some View {
        NetworkDetailsView(title: "Request") { viewModel.render() }
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
final class NetworkRequestInfoCellViewModel {
    let httpMethod: String
    let url: String
    let render: () -> NSAttributedString

    init(task: NetworkTaskEntity) {
        self.httpMethod = task.httpMethod ?? "GET"
        self.url = task.url ?? "–"
        self.render = {
            TextRenderer(options: .sharing).make { $0.render(task, content: .all) }
        }
    }

    init(transaction: NetworkTransactionMetricsEntity) {
        self.httpMethod = transaction.request.httpMethod ?? "GET"
        self.url = transaction.request.url ?? "–"
        self.render = { TextRenderer(options: .sharing).make { $0.render(transaction) } }
    }
}

#if DEBUG
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct NetworkRequestInfoCell_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                ForEach(MockTask.allEntities, id: \.objectID) { task in
                    NetworkRequestInfoCell(viewModel: .init(task: task))
                }
            }
#if os(macOS)
            .frame(width: ConsoleView.contentColumnWidth)
#endif
        }
    }
}
#endif
