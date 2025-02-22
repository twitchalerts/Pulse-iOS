// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import Foundation
import Pulse
import CoreData


@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct ConsoleCustomNetworkFilter: Hashable, Identifiable {
    let id = UUID()
    var field: Field
    var match: Match
    var value: String

    static var `default`: ConsoleCustomNetworkFilter {
        ConsoleCustomNetworkFilter(field: .url, match: .contains, value: "")
    }

    init(field: Field, match: Match, value: String) {
        self.field = field
        self.match = match
        self.value = value
    }


    static func == (lhs: ConsoleCustomNetworkFilter, rhs: ConsoleCustomNetworkFilter) -> Bool {
        (lhs.field, lhs.match, lhs.value) == (rhs.field, rhs.match, rhs.value)
    }

    func hash(into hasher: inout Hasher) {
        field.hash(into: &hasher)
        match.hash(into: &hasher)
        value.hash(into: &hasher)
    }

    enum Field {
        case url
        case host
        case method
        case statusCode
        case errorCode
        case requestHeader
        case responseHeader

        var localizedTitle: String {
            switch self {
            case .url: return "URL"
            case .host: return "Host"
            case .method: return "Method"
            case .statusCode: return "Status Code"
            case .errorCode: return "Error Code"
            case .requestHeader: return "Request Headers"
            case .responseHeader: return "Response Headers"
            }
        }
    }

    enum Match {
        case equal // LIKE[c]
        case notEqual
        case contains
        case notContains
        case regex
        case beginsWith

        var localizedTitle: String {
            switch self {
            case .equal: return "Equal"
            case .notEqual: return "Not Equal"
            case .contains: return "Contains"
            case .notContains: return "Not Contains"
            case .regex: return "Regex"
            case .beginsWith: return "Begins With"
            }
        }
    }

    func makePredicate() -> NSPredicate? {
        guard let key = self.key else {
            return nil
        }
        switch match {
        case .equal: return NSPredicate(format: "\(key) LIKE[c] %@", value)
        case .notEqual: return NSPredicate(format: "NOT (\(key) LIKE[c] %@)", value)
        case .contains: return NSPredicate(format: "\(key) CONTAINS[c] %@", value)
        case .notContains: return NSPredicate(format: "NOT (\(key) CONTAINS[c] %@)", value)
        case .beginsWith: return NSPredicate(format: "\(key) BEGINSWITH[c] %@", value)
        case .regex: return NSPredicate(format: "\(key) MATCHES %@", value)
        }
    }

    func matches(string: String) -> Bool {
        switch match {
        case .equal: return string.caseInsensitiveCompare(value) == .orderedSame
        case .notEqual: return string.caseInsensitiveCompare(value) != .orderedSame
        case .contains: return string.firstRange(of: value, options: [.caseInsensitive]) != nil
        case .notContains: return string.firstRange(of: value, options: [.caseInsensitive]) == nil
        case .regex: return string.firstRange(of: value, options: [.caseInsensitive, .regularExpression]) != nil
        case .beginsWith: return string.firstRange(of: value, options: [.caseInsensitive, .anchored]) != nil
        }
    }

    private var key: String? {
        switch field {
        case .url: return "url"
        case .host: return "host"
        case .method: return "httpMethod"
        case .statusCode: return "statusCode"
        case .errorCode: return "errorCode"
        case .requestHeader: return "originalRequest.httpHeaders"
        case .responseHeader: return "response.httpHeaders"
        }
    }
}
