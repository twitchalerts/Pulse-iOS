// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Pulse


@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct NetworkInspectorSectionRequest: View {
    let viewModel: NetworkInspectorViewModel
    let isCurrentRequest: Bool

    var body: some View {
        viewModel.requestBodyViewModel.map(NetworkRequestBodyCell.init)
        if isCurrentRequest {
            viewModel.currentRequestHeadersViewModel.map(NetworkHeadersCell.init)
            viewModel.currentRequestCookiesViewModel.map(NetworkCookiesCell.init)
        } else {
            viewModel.originalRequestHeadersViewModel.map(NetworkHeadersCell.init)
            viewModel.originalRequestCookiesViewModel.map(NetworkCookiesCell.init)
        }
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct NetworkInspectorSectionResponse: View {
    let viewModel: NetworkInspectorViewModel

    var body: some View {
        viewModel.responseBodyViewModel.map(NetworkResponseBodyCell.init)
        viewModel.responseHeadersViewModel.map(NetworkHeadersCell.init)
        viewModel.responseCookiesViewModel.map(NetworkCookiesCell.init)
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct NetworkInspectorSectionTransferStatus: View {
    @ObservedObject var viewModel: NetworkInspectorViewModel

    var body: some View {
        ZStack {
            NetworkInspectorTransferInfoView(viewModel: .init(empty: true))
                .hidden()
                .accessibilityHidden(true)
            if let transfer = viewModel.transferViewModel {
                NetworkInspectorTransferInfoView(viewModel: transfer)
            } else if let progress = viewModel.progressViewModel {
                SpinnerView(viewModel: progress)
            } else if let status = viewModel.statusSectionViewModel?.status {
                // Fallback in case metrics are disabled
                Image(systemName: status.imageName)
                    .foregroundColor(status.tintColor)
                    .font(.system(size: 64))
            } // Should never happen
        }
    }
}


@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct NetworkInspectorRequestTypePicker: View {
    @Binding var isCurrentRequest: Bool

    var body: some View {
        Picker("Request Type", selection: $isCurrentRequest) {
            Text("Original").tag(false)
            Text("Current").tag(true)
        }
    }
}
