// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import Foundation
import Combine
import Pulse
import SwiftUI
import CoreData
import Charts

#if os(iOS)


@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct InsightsView: View {
    @ObservedObject var viewModel: InsightsViewModel

    private var insights: NetworkLoggerInsights { viewModel.insights }

    init(viewModel: InsightsViewModel) {
        self.viewModel = viewModel
    }

    init(store: LoggerStore) {
        self.viewModel = InsightsViewModel(store: store)
    }

    var body: some View {
        List {
            Section(header: Text("Transfer Size")) {
                NetworkInspectorTransferInfoView(viewModel: .init(transferSize: insights.transferSize))
                    .padding(.vertical, 8)
            }
            durationSection
            if insights.failures.count > 0 {
                failuresSection
            }
//            if insights.redirects.count > 0 {
                redirectsSection
//            }
        }
        .listStyle(.automatic)
        .navigationTitle("Insights")
        .navigationBarItems(leading: navigationTrailingBarItems)
    }

    private var navigationTrailingBarItems: some View {
        Button("Reset") {
            viewModel.insights.reset()
        }
    }

    // MARK: - Duration

    private var durationSection: some View {
        Section(header: Text("Duration")) {
            InfoRow(title: "Median Duration", details: viewModel.medianDuration)
            InfoRow(title: "Duration Range", details: viewModel.durationRange)
            durationChart
            NavigationLink(destination: TopSlowestRequestsViw(viewModel: viewModel)) {
                Text("Show Slowest Requests")
            }.disabled(insights.duration.topSlowestRequests.isEmpty)
        }
    }

    @ViewBuilder
    private var durationChart: some View {
        if #available(iOS 16.0, *) {
            if insights.duration.values.isEmpty {
                Text("No network requests yet")
                    .foregroundColor(.secondary)
                    .frame(height: 140)
            } else {
                Chart(viewModel.durationBars) {
                    BarMark(
                        x: .value("Duration", $0.range),
                        y: .value("Count", $0.count)
                    ).foregroundStyle(barMarkColor(for: $0.range.lowerBound))
                }
                .chartXScale(domain: .automatic(includesZero: false))
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 8)) { value in
                        AxisValueLabel() {
                            if let value = value.as(TimeInterval.self) {
                                Text(DurationFormatter.string(from: TimeInterval(value), isPrecise: false))
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
                .frame(height: 140)
            }
        }
    }

    private func barMarkColor(for duration: TimeInterval) -> Color {
        if duration < 1.0 {
            return Color.green
        } else if duration < 1.9 {
            return Color.yellow
        } else {
            return Color.red
        }
    }

    // MARK: - Redirects

    @ViewBuilder
    private var redirectsSection: some View {
        Section(header: HStack {
            if #available(iOS 14.0, *) {
                Label("Redirects", systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
            }
        }) {
            InfoRow(title: "Redirect Count", details: "\(insights.redirects.count)")
            InfoRow(title: "Total Time Lost", details: DurationFormatter.string(from: insights.redirects.timeLost, isPrecise: false))
            NavigationLink(destination: RequestsWithRedirectsView(viewModel: viewModel)) {
                Text("Show Requests with Redirects")
            }.disabled(insights.duration.topSlowestRequests.isEmpty)
        }
    }

    // MARK: - Failures

    @ViewBuilder
    private var failuresSection: some View {
        Section(header: HStack {
            Image(systemName: "xmark.octagon.fill")
                .foregroundColor(.red)
            Text("Failures")
        }) {
            NavigationLink(destination: FailingRequestsListView(viewModel: viewModel)) {
                HStack {
                    Text("Failed Requests")
                    Spacer()
                    Text("\(insights.failures.count)")
                        .foregroundColor(.secondary)
                }
            }.disabled(insights.duration.topSlowestRequests.isEmpty)
        }
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct TopSlowestRequestsViw: View {
    let viewModel: InsightsViewModel

    var body: some View {
        ConsolePlainList( viewModel.topSlowestRequests())
            .inlineNavigationTitle("Slowest Requests")
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct RequestsWithRedirectsView: View {
    let viewModel: InsightsViewModel

    var body: some View {
        ConsolePlainList( viewModel.requestsWithRedirects())
            .inlineNavigationTitle("Redirects")
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct FailingRequestsListView: View {
    let viewModel: InsightsViewModel

    var body: some View {
        ConsolePlainList( viewModel.failedRequests())
            .inlineNavigationTitle("Failed Requests")
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
final class InsightsViewModel: ObservableObject {
    let insights: NetworkLoggerInsights
    private var cancellable: AnyCancellable?

    private let store: LoggerStore

    var medianDuration: String {
        guard let median = insights.duration.median else { return "–" }
        return DurationFormatter.string(from: median, isPrecise: false)
    }

    var durationRange: String {
        guard let min = insights.duration.minimum,
              let max = insights.duration.maximum else {
            return "–"
        }
        if min == max {
            return DurationFormatter.string(from: min, isPrecise: false)
        }
        return "\(DurationFormatter.string(from: min, isPrecise: false)) – \(DurationFormatter.string(from: max, isPrecise: false))"
    }

    @available(iOS 16.0, *)
    struct Bar: Identifiable {
        var id: Int { index }

        let index: Int
        let range: ChartBinRange<TimeInterval>
        var count: Int
    }

    @available(iOS 16.0, *)
    var durationBars: [Bar] {
        let values = insights.duration.values.map { min(3.4, $0) }
        let bins = NumberBins(data: values, desiredCount: 30)
        let groups = Dictionary(grouping: values, by: bins.index)
        return groups.map { key, values in
            Bar(index: key, range: bins[key], count: values.count)
        }
    }

    init(store: LoggerStore, insights: NetworkLoggerInsights = .shared) {
        self.store = store
        self.insights = insights
        cancellable = insights.didUpdate.throttle(for: 1.0, scheduler: DispatchQueue.main, latest: true).sink { [weak self] in
            withAnimation {
                self?.objectWillChange.send()
            }
        }
    }

    // MARK: - Accessing Data

    func topSlowestRequests() -> [NetworkTaskEntity] {
        tasks(with: Array(insights.duration.topSlowestRequests.keys))
            .sorted(by: { $0.duration > $1.duration })
    }

    func requestsWithRedirects() -> [NetworkTaskEntity] {
        tasks(with: Array(insights.redirects.taskIds))
            .sorted(by: { $0.createdAt > $1.createdAt })
    }

    func failedRequests() -> [NetworkTaskEntity] {
         tasks(with: Array(insights.failures.taskIds))
            .sorted(by: { $0.createdAt > $1.createdAt })
    }

    private func tasks(with ids: [UUID]) -> [NetworkTaskEntity] {
        let request = NSFetchRequest<NetworkTaskEntity>(entityName: "\(NetworkTaskEntity.self)")
        request.fetchLimit = ids.count
        request.predicate = NSPredicate(format: "taskId IN %@", ids)

        return (try? store.viewContext.fetch(request)) ?? []
    }
}

#if DEBUG


@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct NetworkInsightsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InsightsView(viewModel: .init(store: LoggerStore.mock))
        }
    }
}

#endif

#endif
