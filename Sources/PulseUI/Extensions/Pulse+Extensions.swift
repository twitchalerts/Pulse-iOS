// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import Foundation
import Pulse
import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension NetworkTaskEntity {
    var requestFileViewerContext: FileViewerViewModel.Context {
        FileViewerViewModel.Context(
            contentType: originalRequest?.contentType,
            originalSize: requestBodySize,
            metadata: metadata,
            isResponse: false,
            error: nil
        )
    }

    var responseFileViewerContext: FileViewerViewModel.Context {
        FileViewerViewModel.Context(
            contentType: response?.contentType,
            originalSize: responseBodySize,
            metadata: metadata,
            isResponse: true,
            error: decodingError
        )
    }
}

extension LoggerMessageEntity {
    var logLevel: LoggerStore.Level {
        LoggerStore.Level(rawValue: level) ?? .debug
    }
}

extension NetworkTaskEntity.State {
    var tintColor: Color {
        switch self {
        case .pending: return .orange
        case .success: return .green
        case .failure: return .red
        }
    }

    var iconSystemName: String {
        switch self {
        case .pending: return "clock.fill"
        case .success: return "checkmark.circle.fill"
        case .failure: return "exclamationmark.octagon.fill"
        }
    }
}
