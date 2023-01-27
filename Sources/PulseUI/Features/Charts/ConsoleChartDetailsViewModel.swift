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

	private var controller: NSFetchedResultsController<NSManagedObject>?

	private let store: LoggerStore
	private let chartInfo: ChartInfoEntity

	public init(store: LoggerStore, chartInfo: ChartInfoEntity) {
		self.store = store
		self.chartInfo = chartInfo

		super.init()

		prepare()
	}
    
	// MARK: -

	private func prepare() {
		chartInfoData = ChartInfo(chartId: chartInfo.chartId, chartName: chartInfo.chartName,
	  		minYScale: chartInfo.minYScale, maxYScale: chartInfo.maxYScale, dataPointWidth: chartInfo.dataPointWidth)

		let request = makePointFetchRequest()
		controller = NSFetchedResultsController(fetchRequest: request,
			managedObjectContext: store.viewContext, sectionNameKeyPath: nil, cacheName: nil)
		controller?.delegate = self

		refresh()
	}
	
	private func makePointFetchRequest() -> NSFetchRequest<NSManagedObject> {
		let request: NSFetchRequest<NSManagedObject> = .init(entityName: "\(ChartPointEntity.self)")
		request.sortDescriptors = [NSSortDescriptor(keyPath: \ChartPointEntity.createdAt, ascending: true)]
		return request
	}

	private func refresh() {
		guard let controller = controller else { return assertionFailure() }

		controller.fetchRequest.predicate = ConsoleSearchCriteria.makeChartDataPredicates(chartId: chartInfo.chartId)

		do {
			try controller.performFetch()
		}
		catch {
			print(error.localizedDescription)
		}

		reloadChartPoints()
	}

	private func reloadChartPoints(diff: CollectionDifference<NSManagedObjectID>? = nil) {
		guard let points = controller?.fetchedObjects?.compactMap ({ $0 as? ChartPointEntity }) else { return }

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

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension ConsoleChartDetailsViewModel: NSFetchedResultsControllerDelegate {
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
					didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
		reloadChartPoints(diff: diff)
	}
}
