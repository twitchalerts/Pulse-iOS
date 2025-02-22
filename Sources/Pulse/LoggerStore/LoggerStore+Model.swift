// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import CoreData

extension LoggerStore {
    /// Returns Core Data model used by the store.
    static let model: NSManagedObjectModel = {
        typealias Entity = NSEntityDescription
        typealias Attribute = NSAttributeDescription
        typealias Relationship = NSRelationshipDescription

        let session = Entity(class: LoggerSessionEntity.self)

        let message = Entity(class: LoggerMessageEntity.self)

        let task = Entity(class: NetworkTaskEntity.self)
        let progress = Entity(class: NetworkTaskProgressEntity.self)
        let request = Entity(class: NetworkRequestEntity.self)
        let response = Entity(class: NetworkResponseEntity.self)
        let transaction = Entity(class: NetworkTransactionMetricsEntity.self)

        let chartInfo = Entity(class: ChartEntity.self)
        let chartPoint = Entity(class: ChartPointEntity.self)

        let blob = Entity(class: LoggerBlobHandleEntity.self)

        session.properties = [
            Attribute(name: "sessionID", type: .integer64AttributeType),
            Attribute(name: "createdAt", type: .dateAttributeType)
        ]

        message.properties = [
            Attribute(name: "createdAt", type: .dateAttributeType),
            Attribute(name: "isPinned", type: .booleanAttributeType),
            Attribute(name: "sessionID", type: .integer64AttributeType),
            Attribute(name: "level", type: .integer16AttributeType),
            Attribute(name: "text", type: .stringAttributeType),
            Attribute(name: "file", type: .stringAttributeType),
            Attribute(name: "function", type: .stringAttributeType),
            Attribute(name: "line", type: .integer32AttributeType),
            Attribute(name: "rawMetadata", type: .stringAttributeType),
            Attribute(name: "label", type: .stringAttributeType),
            Relationship(name: "task", type: .oneToOne(isOptional: true), entity: task),
            Relationship(name: "chart", type: .oneToOne(isOptional: true), entity: chartInfo),
        ]

        task.properties = [
            Attribute(name: "createdAt", type: .dateAttributeType),
            Attribute(name: "sessionID", type: .integer64AttributeType),
            Attribute(name: "taskId", type: .UUIDAttributeType),
            Attribute(name: "taskType", type: .integer16AttributeType),
            Attribute(name: "url", type: .stringAttributeType),
            Attribute(name: "host", type: .stringAttributeType),
            Attribute(name: "httpMethod", type: .stringAttributeType),
            Attribute(name: "statusCode", type: .integer32AttributeType),
            Attribute(name: "errorCode", type: .integer32AttributeType),
            Attribute(name: "errorDomain", type: .stringAttributeType),
            Attribute(name: "errorDebugDescription", type: .stringAttributeType),
            Attribute(name: "underlyingError", type: .binaryDataAttributeType),
            Attribute(name: "startDate", type: .dateAttributeType),
            Attribute(name: "duration", type: .doubleAttributeType),
            Attribute(name: "redirectCount", type: .integer16AttributeType),
            Attribute(name: "responseContentType", type: .stringAttributeType),
            Attribute(name: "requestState", type: .integer16AttributeType),
            Attribute(name: "requestBodySize", type: .integer64AttributeType),
            Attribute(name: "responseBodySize", type: .integer64AttributeType),
            Attribute(name: "isFromCache", type: .booleanAttributeType),
            Attribute(name: "rawMetadata", type: .stringAttributeType),
            Relationship(name: "originalRequest", type: .oneToOne(), entity: request),
            Relationship(name: "currentRequest", type: .oneToOne(isOptional: true), entity: request),
            Relationship(name: "response", type: .oneToOne(isOptional: true), entity: response),
            Relationship(name: "transactions", type: .oneToMany, entity: transaction),
            Relationship(name: "message", type: .oneToOne(), entity: message),
            Relationship(name: "requestBody", type: .oneToOne(isOptional: true), deleteRule: .noActionDeleteRule, entity: blob),
            Relationship(name: "responseBody", type: .oneToOne(isOptional: true), deleteRule: .noActionDeleteRule, entity: blob),
            Relationship(name: "progress", type: .oneToOne(isOptional: true), entity: progress)
        ]

        request.properties = [
            Attribute(name: "url", type: .stringAttributeType),
            Attribute(name: "httpMethod", type: .stringAttributeType) { $0.isOptional = true },
            Attribute(name: "httpHeaders", type: .stringAttributeType),
            Attribute(name: "allowsCellularAccess", type: .booleanAttributeType),
            Attribute(name: "allowsExpensiveNetworkAccess", type: .booleanAttributeType),
            Attribute(name: "allowsConstrainedNetworkAccess", type: .booleanAttributeType),
            Attribute(name: "httpShouldHandleCookies", type: .booleanAttributeType),
            Attribute(name: "httpShouldUsePipelining", type: .booleanAttributeType),
            Attribute(name: "timeoutInterval", type: .integer32AttributeType),
            Attribute(name: "rawCachePolicy", type: .integer16AttributeType)
        ]

        response.properties = [
            Attribute(name: "statusCode", type: .integer16AttributeType),
            Attribute(name: "httpHeaders", type: .stringAttributeType),
        ]

        progress.properties = [
            Attribute(name: "completedUnitCount", type: .integer64AttributeType),
            Attribute(name: "totalUnitCount", type: .integer64AttributeType)
        ]

        transaction.properties = [
            Attribute(name: "index", type: .integer16AttributeType),
            Attribute(name: "rawFetchType", type: .integer16AttributeType),
            Relationship(name: "request", type: .oneToOne(), entity: request),
            Relationship(name: "response", type: .oneToOne(isOptional: true), entity: response),
            Attribute(name: "networkProtocol", type: .stringAttributeType),
            Attribute(name: "localAddress", type: .stringAttributeType),
            Attribute(name: "remoteAddress", type: .stringAttributeType),
            Attribute(name: "localPort", type: .integer32AttributeType),
            Attribute(name: "remotePort", type: .integer32AttributeType),
            Attribute(name: "isProxyConnection", type: .booleanAttributeType),
            Attribute(name: "isReusedConnection", type: .booleanAttributeType),
            Attribute(name: "isCellular", type: .booleanAttributeType),
            Attribute(name: "isExpensive", type: .booleanAttributeType),
            Attribute(name: "isConstrained", type: .booleanAttributeType),
            Attribute(name: "isMultipath", type: .booleanAttributeType),
            Attribute(name: "rawNegotiatedTLSProtocolVersion", type: .integer32AttributeType),
            Attribute(name: "rawNegotiatedTLSCipherSuite", type: .integer32AttributeType),
            Attribute(name: "fetchStartDate", type: .dateAttributeType),
            Attribute(name: "domainLookupStartDate", type: .dateAttributeType),
            Attribute(name: "domainLookupEndDate", type: .dateAttributeType),
            Attribute(name: "connectStartDate", type: .dateAttributeType),
            Attribute(name: "secureConnectionStartDate", type: .dateAttributeType),
            Attribute(name: "secureConnectionEndDate", type: .dateAttributeType),
            Attribute(name: "connectEndDate", type: .dateAttributeType),
            Attribute(name: "requestStartDate", type: .dateAttributeType),
            Attribute(name: "requestEndDate", type: .dateAttributeType),
            Attribute(name: "responseStartDate", type: .dateAttributeType),
            Attribute(name: "responseEndDate", type: .dateAttributeType),
            Attribute(name: "requestHeaderBytesSent", type: .integer64AttributeType),
            Attribute(name: "requestBodyBytesBeforeEncoding", type: .integer64AttributeType),
            Attribute(name: "requestBodyBytesSent", type: .integer64AttributeType),
            Attribute(name: "responseHeaderBytesReceived", type: .integer64AttributeType),
            Attribute(name: "responseBodyBytesAfterDecoding", type: .integer64AttributeType),
            Attribute(name: "responseBodyBytesReceived", type: .integer64AttributeType)
        ]

        chartInfo.properties = [
            Attribute(name: "createdAt", type: .dateAttributeType),
            Attribute(name: "chartId", type: .UUIDAttributeType),
            Attribute(name: "chartName", type: .stringAttributeType),
            Attribute(name: "minYScale", type: .doubleAttributeType),
            Attribute(name: "maxYScale", type: .doubleAttributeType),
            Attribute(name: "dataPointWidth", type: .doubleAttributeType),
            Relationship(name: "message", type: .oneToOne(isOptional: true), entity: message),
            Relationship(name: "points", type: .oneToMany, entity: chartPoint),
        ]

        chartPoint.properties = [
            Attribute(name: "createdAt", type: .dateAttributeType),
            Attribute(name: "pointId", type: .UUIDAttributeType),
            Attribute(name: "chartId", type: .UUIDAttributeType),
            Attribute(name: "value", type: .doubleAttributeType),
            Attribute(name: "timestamp", type: .dateAttributeType),
        ]

        blob.properties = [
            Attribute(name: "key", type: .binaryDataAttributeType),
            Attribute(name: "size", type: .integer32AttributeType),
            Attribute(name: "decompressedSize", type: .integer32AttributeType),
            Attribute(name: "linkCount", type: .integer16AttributeType),
            Attribute(name: "rawContentType", type: .stringAttributeType),
            Attribute(name: "inlineData", type: .binaryDataAttributeType)
        ]

        let model = NSManagedObjectModel()
        model.entities = [session, message, task, progress, chartInfo, chartPoint,
                          blob, request, response, transaction]
        return model
    }()
}
