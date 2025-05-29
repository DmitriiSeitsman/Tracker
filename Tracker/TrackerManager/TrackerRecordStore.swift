import CoreData

final class TrackerRecordStore {
    static let shared = TrackerRecordStore()
    private let context = CoreDataManager.shared.context

    private init() {}

    // MARK: - Add Record

    func addRecord(for id: UUID, on date: Date) {
        let entity = TrackerRecordEntity(context: context)
        entity.id = id
        entity.date = date
        CoreDataManager.shared.saveContext()
    }

    func addRecord(_ record: TrackerRecord) {
        addRecord(for: record.id, on: record.date)
    }

    // MARK: - Remove Record

    func removeRecord(for id: UUID, on date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)

        let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let request: NSFetchRequest<TrackerRecordEntity> = TrackerRecordEntity.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "id == %@", id as CVarArg),
            NSPredicate(format: "date >= %@ AND date < %@", startOfDay as CVarArg, nextDay as CVarArg)
        ])

        if let result = try? context.fetch(request), let entity = result.first {
            context.delete(entity)
            CoreDataManager.shared.saveContext()
        }
    }


    func deleteRecord(_ record: TrackerRecord) {
        removeRecord(for: record.id, on: record.date)
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
}

