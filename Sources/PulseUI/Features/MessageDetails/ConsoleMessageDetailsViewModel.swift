// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import CoreData
import Pulse
import Combine
import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
final class ConsoleMessageDetailsViewModel {
    let textViewModel: RichTextViewModel

    let tags: [ConsoleMessageTagViewModel]
    let text: String
    let message: LoggerMessageEntity

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        #if os(watchOS)
        formatter.dateFormat = "HH:mm:ss.SSS"
        #else
        formatter.dateFormat = "HH:mm:ss.SSS, yyyy-MM-dd"
        #endif
        return formatter
    }()

    init(message: LoggerMessageEntity) {
        let string = TextRenderer().preformatted(message.text)
        self.textViewModel = RichTextViewModel(string: string)

        self.message = message
        self.tags = [
            ConsoleMessageTagViewModel(
                title: "Date",
                value: ConsoleMessageDetailsViewModel.dateFormatter
                    .string(from: message.createdAt)
            ),
            ConsoleMessageTagViewModel(title: "Label", value: message.label)
        ]
        self.text = message.text
    }

    func prepareForSharing() -> Any {
        text
    }

    var pin: PinButtonViewModel {
        PinButtonViewModel(message)
    }
}

private extension Color {
    init(level: LoggerStore.Level) {
        switch level {
        case .critical: self = .red
        case .error: self = .red
        case .warning: self = .orange
        case .info: self = .blue
        case .notice: self = .indigo
        case .debug: self = .secondaryFill
        case .trace: self = .secondaryFill
        }
    }
}


@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct ConsoleMessageTagViewModel {
    let title: String
    let value: String
}
