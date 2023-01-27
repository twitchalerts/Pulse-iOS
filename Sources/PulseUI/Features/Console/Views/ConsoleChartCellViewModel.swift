//
//  ConsoleChartInfoViewModel.swift
//  PulseUI
//
//  Created by Lev Sokolov on 2023-01-24.
//  Copyright © 2023 kean. All rights reserved.
//

import SwiftUI
import Pulse
import CoreData
import Combine

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
final class ConsoleChartCellViewModel {
	let chartInfo: ChartEntity

	var preprocessedText: String { chartInfo.chartName }

	private(set) lazy var time = ConsoleMessageCellViewModel.timeFormatter.string(from: chartInfo.createdAt)

	static let timeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US")
		formatter.dateFormat = "HH:mm:ss.SSS"
		return formatter
	}()

	init(chartInfo: ChartEntity) {
		self.chartInfo = chartInfo
	}

	// MARK: Context Menu

#if os(iOS) || os(macOS)
	func share() -> ShareItems {
		ShareItems([chartInfo.chartName])
	}

	func copy() -> String {
		chartInfo.chartName
	}

	var focusLabel: String {
		"CHART"
	}

	func focus() {

	}

	func hide() {

	}
#endif
}
