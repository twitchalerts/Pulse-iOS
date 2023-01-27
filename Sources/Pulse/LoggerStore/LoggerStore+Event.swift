// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import Foundation

extension LoggerStore {
    /// The events used for syncing data between stores.
    @frozen public enum Event: Sendable {
        case messageStored(MessageCreated)
        case networkTaskCreated(NetworkTaskCreated)
        case networkTaskProgressUpdated(NetworkTaskProgressUpdated)
        case networkTaskCompleted(NetworkTaskCompleted)
        case chartInfoStored(ChartInfoStored)
        case chartPointStored(ChartPointStored)

        public struct MessageCreated: Codable, Sendable {
            public var createdAt: Date
            public var label: String
            public var level: LoggerStore.Level
            public var message: String
            public var metadata: [String: String]?
            public var sessionID: Int64
            public var file: String
            public var function: String
            public var line: UInt

            public init(createdAt: Date, label: String, level: LoggerStore.Level, message: String, metadata: [String: String]?, sessionID: Int64, file: String, function: String, line: UInt) {
                self.createdAt = createdAt
                self.label = label
                self.level = level
                self.message = message
                self.metadata = metadata
                self.sessionID = sessionID
                self.file = file
                self.function = function
                self.line = line
            }
        }

        public struct NetworkTaskCreated: Codable, Sendable {
            public var taskId: UUID
            public var taskType: NetworkLogger.TaskType
            public var createdAt: Date
            public var originalRequest: NetworkLogger.Request
            public var currentRequest: NetworkLogger.Request?
            public var sessionID: Int64

            public init(taskId: UUID, taskType: NetworkLogger.TaskType, createdAt: Date, originalRequest: NetworkLogger.Request, currentRequest: NetworkLogger.Request?, sessionID: Int64) {
                self.taskId = taskId
                self.taskType = taskType
                self.createdAt = createdAt
                self.originalRequest = originalRequest
                self.currentRequest = currentRequest
                self.sessionID = sessionID
            }
        }

        public struct NetworkTaskProgressUpdated: Codable, Sendable {
            public var taskId: UUID
            public var url: URL?
            public var completedUnitCount: Int64
            public var totalUnitCount: Int64

            public init(taskId: UUID, url: URL?, completedUnitCount: Int64, totalUnitCount: Int64) {
                self.taskId = taskId
                self.url = url
                self.completedUnitCount = completedUnitCount
                self.totalUnitCount = totalUnitCount
            }
        }

        public struct NetworkTaskCompleted: Codable, Sendable {
            public var taskId: UUID
            public var taskType: NetworkLogger.TaskType
            public var createdAt: Date
            public var originalRequest: NetworkLogger.Request
            public var currentRequest: NetworkLogger.Request?
            public var response: NetworkLogger.Response?
            public var error: NetworkLogger.ResponseError?
            public var requestBody: Data?
            public var responseBody: Data?
            public var metrics: NetworkLogger.Metrics?
            public var sessionID: Int64

            public init(taskId: UUID, taskType: NetworkLogger.TaskType, createdAt: Date, originalRequest: NetworkLogger.Request, currentRequest: NetworkLogger.Request?, response: NetworkLogger.Response?, error: NetworkLogger.ResponseError?, requestBody: Data?, responseBody: Data?, metrics: NetworkLogger.Metrics?, sessionID: Int64) {
                self.taskId = taskId
                self.taskType = taskType
                self.createdAt = createdAt
                self.originalRequest = originalRequest
                self.currentRequest = currentRequest
                self.response = response
                self.error = error
                self.requestBody = requestBody
                self.responseBody = responseBody
                self.metrics = metrics
                self.sessionID = sessionID
            }
        }

        public struct ChartInfoStored: Codable, Sendable {
            public var createdAt: Date
            public var chartId: UUID
            public var chartName: String
            public var minYScale: Double
            public var maxYScale: Double
            public var dataPointWidth: Double

            public init(createdAt: Date, chartId: UUID, chartName: String, minYScale: Double, maxYScale: Double,
                        dataPointWidth: Double) {
                self.createdAt = createdAt
                self.chartId = chartId
                self.chartName = chartName
                self.minYScale = minYScale
                self.maxYScale = maxYScale
                self.dataPointWidth = dataPointWidth
            }
        }

        public struct ChartPointStored: Codable, Sendable {
            public var createdAt: Date
            public var chartId: UUID
            public var pointId: UUID
            public var value: Double
            public var timestamp: Date

            public init(createdAt: Date, chartId: UUID, pointId: UUID, value: Double, timestamp: Date) {
                self.createdAt = createdAt
                self.chartId = chartId
                self.pointId = pointId
                self.value = value
                self.timestamp = timestamp
            }
        }

        var url: URL? {
            switch self {
            case .messageStored:
                return nil
            case .networkTaskCreated(let event):
                return event.originalRequest.url
            case .networkTaskProgressUpdated(let event):
                return event.url
            case .networkTaskCompleted(let event):
                return event.originalRequest.url
            case .chartInfoStored, .chartPointStored:
                return nil
            }
        }
    }
}
