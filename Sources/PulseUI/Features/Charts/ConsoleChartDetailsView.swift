//
// Created by Lev Sokolov on 2023-01-25.
// Copyright (c) 2023 kean. All rights reserved.
//

import SwiftUI
import Pulse
import Charts

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct ConsoleChartDetailsView: View {
	private struct ViewConstants {
		static let color1 = Color(hue: 0.33, saturation: 0.81, brightness: 0.76)
		static let minYScale = 0
		static let maxYScale = 5000
		static let chartWidth: CGFloat = 350
		static let chartHeight: CGFloat = 400
	}

	struct YAxisWidthPreferenceKey: PreferenceKey {
		static var defaultValue: CGFloat = .zero
		static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
			value = max(value, nextValue())
		}
	}

	struct YAxisWidthModifier: ViewModifier {
		func body(content: Content) -> some View {
			content.background(
					GeometryReader { geometry in
						Color.clear.preference(key: YAxisWidthPreferenceKey.self, value: geometry.size.width)
					}
			)
		}
	}

	@StateObject private var viewModel: ConsoleChartDetailsViewModel

	// Width of the visible plot area
	@State private var chartContentContainerWidth: CGFloat = .zero
	// Width of the yAxis of chart
	@State private var yAxisWidth: CGFloat = .zero
	// Each bar represents a unit duration along xAxis
	@State private var currentUnitOffset: Int = .zero

	public init(store: LoggerStore = .shared, chartInfo: ChartInfoEntity) {
		self.init(viewModel: .init(store: store, chartInfo: chartInfo))
	}

	init(viewModel: ConsoleChartDetailsViewModel) {
		_viewModel = StateObject(wrappedValue: viewModel)
	}

	public var body: some View {
		VStack(spacing: 16) {
            GroupBox(label: Text(viewModel.chartInfoData?.chartName ?? "Unnamed chart")
                .foregroundColor(.secondary)) {
				HStack(alignment: .top, spacing: 0) {
					ScrollView(.horizontal) {
						chartContent()
					}
					chartYAxis()
					.modifier(YAxisWidthModifier())
					.frame(maxWidth: 50)
				}
				.lineSpacing(0)
			}
			.groupBoxStyle(YellowGroupBoxStyle())
			.frame(height: 300)
			Spacer()
            Text(viewModel.chartDescription)
		}
	}

	private func chartContent() -> some View {
		chart()
		.foregroundStyle(.clear)
		.chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisGridLine(centered: false, stroke: StrokeStyle(dash: [1, 2, 3]))
                    .foregroundStyle(Color.red)
                AxisTick(stroke: StrokeStyle(lineWidth: 1))
                    .foregroundStyle(Color.white)
                AxisValueLabel(
                    format: .dateTime
                )
            }
		}
		.chartYAxis {
			AxisMarks(position: .trailing, values: .automatic(desiredCount: 4)) {
				AxisGridLine()
			}
		}
		.frame(width: (viewModel.chartInfoData?.dataPointWidth ?? 10)
               * CGFloat(((Array<ChartData>)(viewModel.pointData)).count))
	}

	private func chartYAxis() -> some View {
		chart()
		.chartYAxis {
			AxisMarks(position: .trailing, values: .automatic(desiredCount: 4))
		}
		.chartPlotStyle { plot in
			plot
			.frame(width: 0)
			.hidden()
		}
	}

	private func chart() -> some View {
		Chart(viewModel.pointData) {
			LineMark(
                x: .value("Date", $0.date),
                y: .value("Value", $0.value)
			)
			.foregroundStyle(ViewConstants.color1)
			.accessibilityLabel("\($0.date)")
			.accessibilityValue("\($0.value)")
		}
		.chartYScale(domain: ViewConstants.minYScale...ViewConstants.maxYScale)
		.chartYScale(domain: ViewConstants.minYScale...ViewConstants.maxYScale)
		.frame(width: (viewModel.chartInfoData?.dataPointWidth ?? 10) * CGFloat(viewModel.pointData.count))
	}
}

private struct YellowGroupBoxStyle: GroupBoxStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.content
				.padding(.top, 30)
				.padding(20)
                .background(Color.gray.opacity(0.15))
				.cornerRadius(20)
				.overlay(
                    configuration.label.padding(10),
                    alignment: .topLeading
				)
	}
}

#if DEBUG
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct ConsoleChartDetailsView_Previews: PreviewProvider {
	static var previews: some View {
        ConsoleChartDetailsView(viewModel: .init(store: .mock, chartInfo: makeMockChartInfoDetails()))
	}
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
func makeMockChartInfoDetails() -> ChartInfoEntity {
    let entity = ChartInfoEntity(context: LoggerStore.mock.viewContext)
    entity.chartName = "Test chart"
	entity.dataPointWidth = 10
	entity.createdAt = Date()
	entity.minYScale = 0
	entity.maxYScale = 5000
	entity.chartId = UUID()
    
    var startDate = Date()
    for _ in 0...100 {
        let chartPoint = ChartPointEntity(context: LoggerStore.mock.viewContext)
        chartPoint.createdAt = startDate
        chartPoint.chartId = entity.chartId
        chartPoint.pointId = UUID()
        chartPoint.value = Double(Int.random(in: 2500...3500))
        chartPoint.timestamp = startDate
        
        startDate.addTimeInterval(1)
    }
    
    return entity
}

#endif
