import CoreData

final class TrackerRecordStore {
    static let shared = TrackerRecordStore()
    private let context = CoreDataManager.shared.context

    private init() {}

    // MARK: - Add Record

    func addRecord(_ record: TrackerRecord) {
        let entity = TrackerRecordEntity(context: context)
        entity.id = record.id
        entity.date = record.date
        CoreDataManager.shared.saveContext()
    }

    // MARK: - Fetch Records

    func fetchAllRecords() -> [TrackerRecord] {
        let request: NSFetchRequest<TrackerRecordEntity> = TrackerRecordEntity.fetchRequest()
        guard let result = try? context.fetch(request) else { return [] }

        return result.compactMap {
            guard let id = $0.id, let date = $0.date else { return nil }
            return TrackerRecord(id: id, date: date)
        }
    }

    func isTrackerCompleted(_ trackerID: UUID, on date: Date) -> Bool {
        let request: NSFetchRequest<TrackerRecordEntity> = TrackerRecordEntity.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "id == %@", trackerID as CVarArg),
            NSPredicate(format: "date == %@", date as CVarArg)
        ])

        let result = try? context.fetch(request)
        return result?.isEmpty == false
    }

    func deleteRecord(_ record: TrackerRecord) {
        let request: NSFetchRequest<TrackerRecordEntity> = TrackerRecordEntity.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "id == %@", record.id as CVarArg),
            NSPredicate(format: "date == %@", record.date as CVarArg)
        ])

        if let result = try? context.fetch(request), let entity = result.first {
            context.delete(entity)
            CoreDataManager.shared.saveContext()
        }
    }
}
