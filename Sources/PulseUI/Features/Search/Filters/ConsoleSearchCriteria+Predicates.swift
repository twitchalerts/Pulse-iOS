// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import Foundation
import Pulse
import CoreData

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension ConsoleSearchCriteria {
    static func makeMessagePredicates(
        criteria: ConsoleSearchCriteria,
        isOnlyErrors: Bool,
        filterTerm: String
    ) -> NSPredicate? {
        var predicates = [NSPredicate]()
        if isOnlyErrors {
            predicates.append(NSPredicate(format: "level IN %@", [LoggerStore.Level.critical, .error].map { $0.rawValue }))
        }
        predicates += makePredicates(for: criteria.shared)
        predicates += makePredicates(for: criteria.messages)
        if filterTerm.count > 1 {
            predicates.append(NSPredicate(format: "text CONTAINS[cd] %@", filterTerm))
        }
        return predicates.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }

    static func makeNetworkPredicates(
        criteria: ConsoleSearchCriteria,
        isOnlyErrors: Bool,
        filterTerm: String
    ) -> NSPredicate? {
        var predicates = [NSPredicate]()
        if isOnlyErrors {
            predicates.append(NSPredicate(format: "requestState == %d", NetworkTaskEntity.State.failure.rawValue))
        }
        predicates += makePredicates(for: criteria.shared, isNetwork: true)
        predicates += makePredicates(for: criteria.network)
        if filterTerm.count > 1 {
            predicates.append(NSPredicate(format: "url CONTAINS[cd] %@", filterTerm))
        }
        return predicates.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }

    static func makeSharedPredicates() -> NSPredicate? {
        var predicates = [NSPredicate]()
        let defaultCriteria = ConsoleSearchCriteria()
        predicates += makePredicates(for: defaultCriteria.shared)
        return predicates.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }

    static func makeChartDataPredicates(chartId: UUID) -> NSPredicate? {
        var predicates = [NSPredicate]()
        let defaultCriteria = ConsoleSearchCriteria()
        predicates += makePredicates(for: defaultCriteria.shared)
        predicates.append(NSPredicate(format: "chartId == %@", chartId as NSUUID))
        return predicates.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private func makePredicates(for criteria: ConsoleSearchCriteria.Shared, isNetwork: Bool = false) -> [NSPredicate] {
    var predicates = [NSPredicate]()

    if criteria.dates.isEnabled {
        if let startDate = criteria.dates.startDate {
            predicates.append(NSPredicate(format: "createdAt >= %@", startDate as NSDate))
        }
        if let endDate = criteria.dates.endDate {
            predicates.append(NSPredicate(format: "createdAt <= %@", endDate as NSDate))
        }
    }

    if criteria.general.isEnabled {
        if criteria.general.inOnlyPins {
            let keyPath = isNetwork ? "message.isPinned" : "isPinned"
            predicates.append(NSPredicate(format: "\(keyPath) == YES"))
        }
    }

    return predicates
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private func makePredicates(for criteria: ConsoleSearchCriteria.Messages) -> [NSPredicate] {
    var predicates = [NSPredicate]()

    if criteria.logLevels.isEnabled {
        if criteria.logLevels.levels.count != LoggerStore.Level.allCases.count {
            predicates.append(NSPredicate(format: "level IN %@", Array(criteria.logLevels.levels.map { $0.rawValue })))
        }
    }

    if criteria.labels.isEnabled {
        if let focusedLabel = criteria.labels.focused {
            predicates.append(NSPredicate(format: "label.name == %@", focusedLabel))
        } else if !criteria.labels.hidden.isEmpty {
            predicates.append(NSPredicate(format: "NOT label.name IN %@", Array(criteria.labels.hidden)))
        }
    }


    if criteria.custom.isEnabled {
        for filter in criteria.custom.filters where !filter.value.isEmpty {
            if let predicate = filter.makePredicate() {
                predicates.append(predicate)
            } else {
                // Have to be done in code
            }
        }
    }

    return predicates
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private func makePredicates(for criteria: ConsoleSearchCriteria.Network) -> [NSPredicate] {
    var predicates = [NSPredicate]()

    if criteria.response.isEnabled {
        if let value = criteria.response.responseSize.byteCountRange.lowerBound {
            predicates.append(NSPredicate(format: "responseBodySize >= %d", value))
        }
        if let value = criteria.response.responseSize.byteCountRange.upperBound {
            predicates.append(NSPredicate(format: "responseBodySize <= %d", value))
        }
        if let value = Int(criteria.response.statusCode.range.lowerBound) {
            predicates.append(NSPredicate(format: "statusCode >= %d", value))
        }
        if let value = Int(criteria.response.statusCode.range.upperBound) {
            predicates.append(NSPredicate(format: "statusCode <= %d", value))
        }
        if let value = criteria.response.duration.durationRange.lowerBound {
            predicates.append(NSPredicate(format: "duration >= %f", value))
        }
        if let value = criteria.response.duration.durationRange.upperBound {
            predicates.append(NSPredicate(format: "duration <= %f", value))
        }
        switch criteria.response.contentType.contentType {
        case .any: break
        default: predicates.append(NSPredicate(format: "responseContentType CONTAINS %@", criteria.response.contentType.contentType.rawValue))
        }
    }

    if criteria.networking.isEnabled {
        if criteria.networking.isRedirect {
            predicates.append(NSPredicate(format: "redirectCount >= 1"))
        }
        switch criteria.networking.source {
        case .any:
            break
        case .network:
            predicates.append(NSPredicate(format: "isFromCache == NO"))
        case .cache:
            predicates.append(NSPredicate(format: "isFromCache == YES"))
        }
        if case .some(let taskType) = criteria.networking.taskType {
            predicates.append(NSPredicate(format: "taskType == %i", taskType.rawValue))
        }
    }

    if criteria.host.isEnabled, !criteria.host.ignoredHosts.isEmpty {
        predicates.append(NSPredicate(format: "NOT host.value IN %@", criteria.host.ignoredHosts))
    }

    if criteria.custom.isEnabled {
        for filter in criteria.custom.filters where !filter.value.isEmpty {
            if let predicate = filter.makePredicate() {
                predicates.append(predicate)
            } else {
                // Have to be done in code
            }
        }
    }

    return predicates
}
