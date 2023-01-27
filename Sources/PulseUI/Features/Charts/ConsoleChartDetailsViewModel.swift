//
// Created by Lev Sokolov on 2023-01-25.
// Copyright (c) 2023 kean. All rights reserved.
//

import CoreData
import Pulse
import Combine

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
final class ConsoleChartDetailsViewModel: NSObject, ObservableObject {

	private static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US")
		formatter.dateFormat = "HH:mm:ss.SSS, yyyy-MM-dd"
		return formatter
	}()

	@Published private(set) var chartInfoData: ChartInfo?
	@Published private(set) var pointData: [ChartData] = []
	@Published private(set) var chartDescription: String = ""

	private let chartInfo: ChartInfoEntity

	public init(store: LoggerStore, chartInfo: ChartInfoEntity) {
		self.chartInfo = chartInfo

		super.init()

		prepare()
	}
    
	// MARK: -

	private func prepare() {
		chartInfoData = ChartInfo(chartId: chartInfo.chartId, chartName: chartInfo.chartName,
	  		minYScale: chartInfo.minYScale, maxYScale: chartInfo.maxYScale, dataPointWidth: chartInfo.dataPointWidth)

		let points = chartInfo.orderedPoints
		pointData = points.map { ChartData(date: $0.createdAt, value: $0.value) }

		chartDescription = ""
		if let firstPoint = points.first {
			chartDescription += "Start: \(Self.dateFormatter.string(from: firstPoint.timestamp))"
		}

		if let lastPoint = points.last {
			chartDescription += "\nEnd: \(Self.dateFormatter.string(from: lastPoint.timestamp))"
		}

		chartDescription += "\nTotal points: \(points.count)"
	}
}

struct ChartInfo: Identifiable, Hashable {
	var chartId: UUID
	var chartName: String
	var minYScale: Double
	var maxYScale: Double
	var dataPointWidth: Double

	init(chartId: UUID, chartName: String, minYScale: Double, maxYScale: Double, dataPointWidth: Double) {
		self.chartId = chartId
		self.chartName = chartName
		self.minYScale = minYScale
		self.maxYScale = maxYScale
		self.dataPointWidth = dataPointWidth
	}

	var id: UUID {
		chartId
	}
}

struct ChartData: Identifiable {
	let id = UUID()

	var date: Date
	var value: Double

	init(date: Date, value: Double) {
		self.date = date
		self.value = value
	}
}
