// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Pulse
import CoreData
import Combine

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
final class ConsoleMessageCellViewModel {
    let message: LoggerMessageEntity

    private let searchCriteriaViewModel: ConsoleSearchCriteriaViewModel?

    // TODO: Trim whitespaces and remove newlines?
    var preprocessedText: String { message.text }
    
    private(set) lazy var time = ConsoleMessageCellViewModel.timeFormatter.string(from: message.createdAt)

    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()

    init(message: LoggerMessageEntity, searchCriteriaViewModel: ConsoleSearchCriteriaViewModel? = nil) {
        self.message = message
        self.searchCriteriaViewModel = searchCriteriaViewModel
    }
    
    // MARK: Context Menu

#if os(iOS) || os(macOS)
    func share() -> ShareItems {
        ShareItems([message.text])
    }

    func focus() {
        searchCriteriaViewModel?.criteria.messages.labels.isEnabled = true
        searchCriteriaViewModel?.criteria.messages.labels.focused = message.label
    }
    
    func hide() {
        searchCriteriaViewModel?.criteria.messages.labels.isEnabled = true
        searchCriteriaViewModel?.criteria.messages.labels.hidden.insert(message.label)
    }
#endif
}

extension UXColor {
    static func textColor(for level: LoggerStore.Level) -> UXColor {
        switch level {
        case .trace: return .secondaryLabel
        case .debug, .info: return .label
        case .notice, .warning: return .systemOrange
#if os(macOS)
        case .error, .critical: return Palette.red
#else
        case .error, .critical: return .red
#endif
        }
    }
}

extension Color {
    static func textColor(for level: LoggerStore.Level) -> Color {
        switch level {
        case .trace: return .secondary
        case .debug, .info: return .primary
        case .notice, .warning: return .orange
#if os(macOS)
        case .error, .critical: return Color(Palette.red)
#else
        case .error, .critical: return .red
#endif
        }
    }
}
