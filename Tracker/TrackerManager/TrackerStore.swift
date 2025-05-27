import CoreData
import UIKit

final class TrackerStore {
    static let shared = TrackerStore()
    private let context = CoreDataManager.shared.context

    private init() {}

    // MARK: - Add Tracker

    func addTracker(_ tracker: Tracker, categoryTitle: String) {
        guard let category = fetchCategoryEntity(by: categoryTitle) else {
            print("⚠️ Не найдена категория \(categoryTitle), трекер не сохранён")
            return
        }

        let entity = TrackerEntity(context: context)
        entity.id = tracker.id
        entity.title = tracker.title
        entity.emoji = tracker.emoji
        entity.colorHex = tracker.color.toHexString()
        
        // Сериализация schedule через NSKeyedArchiver
        let rawValues = tracker.schedule.map { $0.rawValue }
        do {
            let data = try NSKeyedArchiver.archivedData(
                withRootObject: rawValues,
                requiringSecureCoding: true
            )
            entity.schedule = data as NSData
        } catch {
            print("❌ Не удалось сохранить schedule: \(error)")
        }

        entity.category = category

        print("✅ Сохраняем трекер в категорию: \(categoryTitle)")
        CoreDataManager.shared.saveContext()
    }

    // MARK: - Fetch Trackers

    func fetchAllTrackers() -> [TrackerEntity] {
        let request: NSFetchRequest<TrackerEntity> = TrackerEntity.fetchRequest()
        return (try? context.fetch(request)) ?? []
    }

    // MARK: - Fetch Categories

    func fetchAllCategories() -> [TrackerCategory] {
        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        let categoryEntities = (try? context.fetch(request)) ?? []

        print("📦 Загруженные категории: \(categoryEntities.count)")

        return categoryEntities.map { categoryEntity in
            let trackers = (categoryEntity.trackers?.allObjects as? [TrackerEntity] ?? [])
                .compactMap { $0.toTracker() }

            print("📂 \(categoryEntity.name ?? "Без имени"): \(trackers.count) трекеров")

            return TrackerCategory(title: categoryEntity.name ?? "Без имени", trackers: trackers)
        }
    }

    // MARK: - Helpers

    private func fetchCategoryEntity(by title: String) -> CategoryEntity? {
        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", title)
        return try? context.fetch(request).first
    }
}


extension TrackerEntity {
    func toTracker() -> Tracker? {
        guard let id,
              let title,
              let emoji,
              let colorHex,
              let categoryName = category?.name,
              let data = schedule as? Data,
              let raw = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, NSNumber.self], from: data) as? [Int]
        else {
            return nil
        }

        let scheduleSet = Set(raw.compactMap { Tracker.Weekday(rawValue: $0) })

        return Tracker(
            id: id,
            title: title,
            color: UIColor(hex: colorHex),
            emoji: emoji,
            schedule: scheduleSet,
            categoryName: categoryName
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

