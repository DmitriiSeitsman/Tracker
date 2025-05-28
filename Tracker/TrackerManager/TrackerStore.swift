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

        let entity = TrackerEntity(context: context)
        entity.id = tracker.id
        entity.title = tracker.title
        entity.emoji = tracker.emoji
        entity.colorHex = tracker.color.toHexString()
        entity.createdAt = createdAt // 👈 вот это

        // сериализуем пустой schedule как []
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
        guard let id else {
            print("❌ Не удалось получить id")
            return nil
        }

        guard let title else {
            print("❌ Не удалось получить title")
            return nil
        }

        guard let emoji else {
            print("❌ Не удалось получить emoji")
            return nil
        }

        guard let colorHex else {
            print("❌ Не удалось получить colorHex")
            return nil
        }

        guard let categoryName = category?.name else {
            print("❌ Не удалось получить имя категории")
            return nil
        }

        guard let createdAt else {
            print("❌ Не удалось получить createdAt")
            return nil
        }

        let scheduleSet: Set<Tracker.Weekday> = {
            guard let data = schedule else {
                print("⚠️ schedule не является Data")
                return []
            }


            guard let raw = try? NSKeyedUnarchiver.unarchivedObject(
                ofClasses: [NSArray.self, NSNumber.self],
                from: data
            ) as? [Int] else {
                print("⚠️ Не удалось декодировать schedule")
                return []
            }

            return Set(raw.compactMap { Tracker.Weekday(rawValue: $0) })
        }()

        return Tracker(
            id: id,
            title: title,
            color: UIColor(hex: colorHex),
            emoji: emoji,
            schedule: scheduleSet,
            categoryName: categoryName,
            createdAt: createdAt
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

