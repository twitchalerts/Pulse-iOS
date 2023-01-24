//
// Created by Lev Sokolov on 2023-01-19.
// Copyright (c) 2023 kean. All rights reserved.
//

import CoreData
import Pulse
import Combine

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
final class ChartViewModel: NSObject, ObservableObject {

	let store: LoggerStore
	
	@Published private(set) var infoData: [ChartInfo] = []
	@Published private(set) var pointData: [UUID: [ChartData]] = [:]

	private var chartInfoController: NSFetchedResultsController<NSManagedObject>?
	private var chartPointController: NSFetchedResultsController<NSManagedObject>?

	init(store: LoggerStore) {
		self.store = store
		
		super.init()

		prepare()
	}

    func points(for chartId: UUID) -> Int {
        pointData[chartId]?.count ?? 0
    }

	// MARK: -
	
	private func prepare() {
		let infoRequest = makeInfoFetchRequest()
		chartInfoController = NSFetchedResultsController(fetchRequest: infoRequest,
			managedObjectContext: store.viewContext, sectionNameKeyPath: nil, cacheName: nil)
		chartInfoController?.delegate = self

		let pointRequest = makePointFetchRequest()
		chartPointController = NSFetchedResultsController(fetchRequest: pointRequest,
			managedObjectContext: store.viewContext, sectionNameKeyPath: nil, cacheName: nil)
		chartPointController?.delegate = self

        refresh()
	}
	
	private func makeInfoFetchRequest() -> NSFetchRequest<NSManagedObject> {
		let request: NSFetchRequest<NSManagedObject> = .init(entityName: "\(ChartInfoEntity.self)")
		request.sortDescriptors = [NSSortDescriptor(keyPath: \ChartInfoEntity.createdAt, ascending: false)]
		request.fetchBatchSize = 10
		return request
	}

	private func makePointFetchRequest() -> NSFetchRequest<NSManagedObject> {
		let request: NSFetchRequest<NSManagedObject> = .init(entityName: "\(ChartPointEntity.self)")
		request.sortDescriptors = [NSSortDescriptor(keyPath: \ChartPointEntity.createdAt, ascending: false)]
		return request
	}
	
	private func refresh() {
		guard let infoController = chartInfoController else { return assertionFailure() }
		guard let pointController = chartPointController else { return assertionFailure() }

		infoController.fetchRequest.predicate = ConsoleSearchCriteria.makeSharedPredicates()
		pointController.fetchRequest.predicate = ConsoleSearchCriteria.makeSharedPredicates()

        do {
            try infoController.performFetch()
            try pointController.performFetch()
        }
        catch {
            print(error.localizedDescription)
        }

		reloadChartInfo()
		reloadChartPoints()
	}
	
	private func reloadChartInfo(diff: CollectionDifference<NSManagedObjectID>? = nil) {
		infoData = chartInfoController?.fetchedObjects?.compactMap { $0 as? ChartInfoEntity }.map {
			ChartInfo(chartId: $0.chartId, chartName: $0.chartName, minYScale: $0.minYScale, maxYScale: $0.maxYScale,
					  dataPointWidth: $0.dataPointWidth)
		} ?? []
	}

	private func reloadChartPoints(diff: CollectionDifference<NSManagedObjectID>? = nil) {
		let fetchedPoints = chartPointController?.fetchedObjects ?? []

		pointData.removeAll()

		for pointEntity in fetchedPoints {
			guard let point = pointEntity as? ChartPointEntity else { continue }

			if pointData[point.chartId] == nil {
				pointData[point.chartId] = []
			}

			pointData[point.chartId]?.append(ChartData(date: point.timestamp, value: point.value))
		}
	}
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension ChartViewModel: NSFetchedResultsControllerDelegate {
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
					didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
		if controller == chartInfoController {
			reloadChartInfo(diff: diff)
		}
		
        if controller == chartPointController {
			reloadChartPoints(diff: diff)
		}
	}
}
