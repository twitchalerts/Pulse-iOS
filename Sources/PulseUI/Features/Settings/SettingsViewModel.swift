// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Pulse
import Combine

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
final class SettingsViewModel: ObservableObject {
    let store: LoggerStore

    var isArchive: Bool { store.isArchive }

    // Apple Watch file transfers
#if os(watchOS) || os(iOS)
    @Published private(set) var fileTransferStatus: FileTransferStatus = .initial
    @Published var fileTransferError: FileTransferError?
#endif

    private var cancellables: [AnyCancellable] = []

    var isRemoteLoggingAvailable: Bool {
        store === RemoteLogger.shared.store
    }

    init(store: LoggerStore) {
        self.store = store

#if os(watchOS) || os(iOS)
        LoggerSyncSession.shared.$fileTransferStatus.sink(receiveValue: { [weak self] in
            self?.fileTransferStatus = $0
            if case let .failure(error) = $0 {
                self?.fileTransferError = FileTransferError(message: error.localizedDescription)
            }
        }).store(in: &cancellables)
#endif
    }

    func buttonRemoveAllMessagesTapped() {
        store.removeAll()

#if os(iOS)
        runHapticFeedback(.success)
        ToastView {
            HStack {
                Image(systemName: "trash")
                Text("All messages removed")
            }
        }.show()
#endif
    }

#if os(watchOS)
    func tranferStore() {
        LoggerSyncSession.shared.transfer(store: store)
    }
#endif
}
