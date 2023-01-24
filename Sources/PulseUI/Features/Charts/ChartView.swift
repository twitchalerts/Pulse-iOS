//
//  ChartView.swift
//  Pulse
//
//  Created by Lev Sokolov on 2023-01-17.
//  Copyright © 2023 kean. All rights reserved.
//

import SwiftUI
import Pulse
import Charts

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct ChartView: View {
    private struct ViewConstants {
        static let color1 = Color(hue: 0.33, saturation: 0.81, brightness: 0.76)
        static let minYScale = 0
        static let maxYScale = 5000
        static let chartWidth: CGFloat = 350
        static let chartHeight: CGFloat = 400
        static let dataPointWidth: CGFloat = 20
    }
    
    struct YAxisWidthPreferenceyKey: PreferenceKey {
        static var defaultValue: CGFloat = .zero
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
    
    struct YAxisWidthModifier: ViewModifier {
        func body(content: Content) -> some View {
            content.background(
                GeometryReader { geometry in
                    Color.clear.preference(key: YAxisWidthPreferenceyKey.self, value: geometry.size.width)
                }
            )
        }
    }

    @StateObject private var viewModel: ChartViewModel
    
    // Width of the visible plot area
    @State private var chartContentContainerWidth: CGFloat = .zero
    // Width of the yAxis of chart
    @State private var yAxisWidth: CGFloat = .zero
    // Each bar represents a unit duration along xAxis
    @State private var currentUnitOffset: Int = .zero

    public init(store: LoggerStore = .shared) {
        self.init(viewModel: .init(store: store))
    }

    init(viewModel: ChartViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 16) {
                ForEach(viewModel.infoData, id: \.self) { info in
                    GroupBox ("\(info.chartName)") {
                        HStack(alignment: .top, spacing: 0) {
                            ScrollView(.horizontal) {
                                chartContent(for: info.chartId)
                                    .frame(width: info.dataPointWidth * CGFloat(viewModel.points(for: info.chartId)))
                            }
                            chartYAxis(for: info.chartId)
                                .modifier(YAxisWidthModifier())
                                .frame(maxWidth: 50)
                        }
                        .lineSpacing(0)
                    }
                    .groupBoxStyle(YellowGroupBoxStyle())
                }
                .frame(height: 250)
                Spacer()
            }
        }
    }
    
    private func chartContent(for chartId: UUID) -> some View {
        chart(for: chartId)
            .foregroundStyle(.clear)
            .chartXAxis {
                AxisMarks(preset: .extended,
                          position: .bottom,
                          values: .stride (by: .day)) { value in
                    AxisValueLabel(
                        format: .dateTime.day(.twoDigits)
                    )
                }
            }
            .chartYAxis() {
                AxisMarks(position: .trailing, values: .automatic(desiredCount: 4)) {
                    AxisGridLine()
                }
            }
    }
    
    private func chartYAxis(for chartId: UUID) -> some View {
        chart(for: chartId)
            .chartYAxis {
                AxisMarks(position: .trailing, values: .automatic(desiredCount: 4))
            }
            .chartPlotStyle { plot in
                plot
                    .frame(width: 0)
                    .hidden()
            }
    }

    private func chart(for chartId: UUID) -> some View {
        Chart(viewModel.pointData[chartId] ?? []) {
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
        .frame(width: ViewConstants.dataPointWidth * CGFloat((viewModel.pointData[chartId] ?? []).count))
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

struct YellowGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .padding(.top, 30)
            .padding(20)
            .background(Color(hue: 0.10, saturation: 0.10, brightness: 0.98))
            .cornerRadius(20)
            .overlay(
                configuration.label.padding(10),
                alignment: .topLeading
            )
    }
}

#if DEBUG
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView(viewModel: .init(store: .mock))
    }
}
#endif
