// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Pulse


@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct NetworkHeadersCell: View {
    let viewModel: NetworkHeadersCellViewModel

    var body: some View {
        NavigationLink(destination: destination) {
            NetworkMenuCell(
                icon: "list.bullet.rectangle.portrait.fill",
                tintColor: .secondary,
                title: viewModel.title,
                details: viewModel.details
            )
        }
        .foregroundColor(viewModel.isEnabled ? nil : .secondary)
        .disabled(!viewModel.isEnabled)
    }

    private var destination: some View {
        NetworkDetailsView(title: viewModel.title) { viewModel.detailsViewModel }
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
final class NetworkHeadersCellViewModel {
    let title: String
    let details: String
    let isEnabled: Bool

    lazy var detailsViewModel = KeyValueSectionViewModel.makeHeaders(title: title, headers: headers)

    private let headers: [String: String]

    init(title: String, headers: [String: String]?) {
        self.title = title
        let headers = headers ?? [:]
        self.details = "\(headers.count)"
        self.isEnabled = !headers.isEmpty
        self.headers = headers
    }
}

#if DEBUG
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct NetworkHeadersCell_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                ForEach(MockTask.allEntities, id: \.objectID) { task in
                    Section {
                        Text(task.url ?? "–")
                        NetworkHeadersCell(viewModel: .init(title: "Original Request Headers", headers: task.originalRequest?.headers))
                        NetworkHeadersCell(viewModel: .init(title: "Current Request Headers", headers: task.currentRequest?.headers))
                        NetworkHeadersCell(viewModel: .init(title: "Response Headers", headers: task.response?.headers))
                    }
                }
            }
#if os(macOS)
            .frame(width: ConsoleView.contentColumnWidth)
#endif
        }
    }
}
#endif
