//
// Created by Lev Sokolov on 2023-01-25.
// Copyright (c) 2023 kean. All rights reserved.
//

import CoreData
import Pulse
import Combine

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
final class ConsoleChartDetailsViewModel: NSObject, ObservableObject {

	@Published private(set) var chartInfoData: ChartInfo?
	@Published private(set) var pointData: [ChartData] = []

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
		request.sortDescriptors = [NSSortDescriptor(keyPath: \ChartPointEntity.createdAt, ascending: false)]
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
		pointData = controller?.fetchedObjects?.compactMap { $0 as? ChartPointEntity }
			.map { ChartData(date: $0.createdAt, value: $0.value) } ?? []
	}
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension ConsoleChartDetailsViewModel: NSFetchedResultsControllerDelegate {
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
					didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
		reloadChartPoints(diff: diff)
	}
}
