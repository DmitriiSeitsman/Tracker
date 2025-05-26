
import CoreData
import UIKit

final class TrackerStore {
    static let shared = TrackerStore()
    private let context = CoreDataManager.shared.context

    private init() {}

    func addTracker(_ tracker: Tracker, categoryTitle: String) {
        let entity = TrackerEntity(context: context)
        entity.id = tracker.id
        entity.title = tracker.title
        entity.emoji = tracker.emoji
        entity.colorHex = tracker.color.toHexString()
        entity.schedule = tracker.schedule.map { NSNumber(value: $0.rawValue) } as NSObject

        // Можешь связать с CategoryEntity, если нужно
        CoreDataManager.shared.saveContext()
    }

    func fetchAllTrackers() -> [Tracker] {
        let request: NSFetchRequest<TrackerEntity> = TrackerEntity.fetchRequest()
        let entities = (try? context.fetch(request)) ?? []

        return entities.map { entity in
            Tracker(
                id: entity.id ?? UUID(),
                title: entity.title ?? "",
                color: UIColor(hex: entity.colorHex ?? "#000000"),
                emoji: entity.emoji ?? "",
                schedule: Set((entity.schedule as? [Int] ?? []).compactMap { Tracker.Weekday(rawValue: $0) })
            )
        }
    }
    
    func fetchAllCategories() -> [TrackerCategory] {
        let trackers = fetchAllTrackers()
        let grouped = Dictionary(grouping: trackers) { tracker in
            return "Без категории"
        }

        return grouped.map { TrackerCategory(title: $0.key, trackers: $0.value) }
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

