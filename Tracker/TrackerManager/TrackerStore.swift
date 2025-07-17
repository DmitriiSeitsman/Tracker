import CoreData
import UIKit

final class TrackerStore {
    static let shared = TrackerStore()
    private let context = CoreDataManager.shared.context

    private init() {}

    // MARK: - Add Tracker

    func addTracker(_ tracker: Tracker, categoryTitle: String, createdAt: Date) {
        guard let category = fetchCategoryEntity(by: categoryTitle) else {
            print("⚠️ Не найдена категория \(categoryTitle), трекер не сохранён")
            return
        }

        let entity = TrackerCoreData(context: context)
        entity.id = tracker.id
        entity.title = tracker.title
        entity.emoji = tracker.emoji
        entity.colorHex = tracker.color.toHexString()
        entity.createdAt = createdAt

        let rawValues = tracker.schedule.map { $0.rawValue }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: rawValues, requiringSecureCoding: true)
            entity.schedule = data
        } catch {
            print("❌ Не удалось сохранить schedule: \(error)")
        }

        entity.category = category
        CoreDataManager.shared.saveContext()
    }

    // MARK: - Update Tracker

    func updateTracker(_ tracker: Tracker, categoryTitle: String) {
        guard let entity = fetchTrackerEntity(by: tracker.id),
              let category = fetchCategoryEntity(by: categoryTitle) else {
            print("❌ Не удалось найти трекер или категорию для обновления")
            return
        }

        entity.title = tracker.title
        entity.emoji = tracker.emoji
        entity.colorHex = tracker.color.toHexString()
        entity.createdAt = tracker.createdAt
        entity.isPinned = tracker.isPinned

        let rawValues = tracker.schedule.map { $0.rawValue }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: rawValues, requiringSecureCoding: true)
            entity.schedule = data
        } catch {
            print("❌ Ошибка при сохранении расписания: \(error)")
        }

        entity.category = category
        CoreDataManager.shared.saveContext()
    }


    func togglePin(for tracker: Tracker) {
        if let entity = fetchTrackerEntity(by: tracker.id) {
            entity.isPinned.toggle()
            CoreDataManager.shared.saveContext()
        }
    }

    func deleteTracker(_ tracker: Tracker) {
        if let entity = fetchTrackerEntity(by: tracker.id) {
            print("🗑 Удаляем трекер: \(entity.title ?? "")")
            print("📦 У него записей: \(entity.records?.count ?? 0)")
            context.delete(entity)
            CoreDataManager.shared.saveContext()

            // Проверим, всё ли удалилось
            let остались = TrackerRecordStore.shared.fetchAllRecords().filter { $0.id == tracker.id }
            print("🔍 Осталось записей с таким id: \(остались.count)")
        }
    }

    // MARK: - Fetch Trackers

    func fetchAllTrackers() -> [TrackerCoreData] {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        return (try? context.fetch(request)) ?? []
    }
    
    func fetchAllTrackersAsModels() -> [Tracker] {
        return fetchAllTrackers().compactMap { $0.toTracker() }
    }


    // MARK: - Fetch Categories

    func fetchAllCategories() -> [TrackerCategory] {
        let request: NSFetchRequest<CategoryCoreData> = CategoryCoreData.fetchRequest()
        let categoryEntities = (try? context.fetch(request)) ?? []

        return categoryEntities.map { categoryEntity in
            let trackers = (categoryEntity.trackers?.allObjects as? [TrackerCoreData] ?? [])
                .compactMap { $0.toTracker() }

            return TrackerCategory(title: categoryEntity.name ?? "Без имени", trackers: trackers)
        }
    }

    // MARK: - Helpers
    
    func fetchTrackerEntity(by id: UUID) -> TrackerCoreData? {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try? context.fetch(request).first
    }

    private func fetchCategoryEntity(by title: String) -> CategoryCoreData? {
        let request: NSFetchRequest<CategoryCoreData> = CategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", title)
        return try? context.fetch(request).first
    }
    
}

extension TrackerCoreData {
    func toTracker() -> Tracker? {
        guard let id = self.id else {
            print("❌ TrackerEntity: id отсутствует")
            return nil
        }
        guard let title = self.title else {
            print("❌ TrackerEntity: title отсутствует")
            return nil
        }
        guard let emoji = self.emoji else {
            print("❌ TrackerEntity: emoji отсутствует")
            return nil
        }
        guard let colorHex = self.colorHex else {
            print("❌ TrackerEntity: colorHex отсутствует")
            return nil
        }
        guard let categoryName = self.category?.name else {
            print("❌ TrackerEntity: категория отсутствует")
            return nil
        }
        guard let createdAt = self.createdAt else {
            print("❌ TrackerEntity: createdAt отсутствует")
            return nil
        }

        // Распаковка schedule
        var scheduleSet = Set<Tracker.Weekday>()
        if let data = self.schedule {
            if let raw = try? NSKeyedUnarchiver.unarchivedObject(
                ofClasses: [NSArray.self, NSNumber.self],
                from: data
            ) as? [Int] {
                scheduleSet = Set(raw.compactMap { Tracker.Weekday(rawValue: $0) })
            }
        }

        return Tracker(
            id: id,
            title: title,
            color: UIColor(hex: colorHex),
            emoji: emoji,
            schedule: scheduleSet,
            categoryName: categoryName,
            createdAt: createdAt,
            isPinned: self.isPinned
        )
    }
}


extension UIColor {
    func toHexString() -> String {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "#%02X%02X%02X",
                      Int(red * 255),
                      Int(green * 255),
                      Int(blue * 255))
    }

    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = CGFloat((rgb >> 16) & 0xFF) / 255
        let g = CGFloat((rgb >> 8) & 0xFF) / 255
        let b = CGFloat(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}

