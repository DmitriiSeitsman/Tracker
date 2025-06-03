import UIKit

struct Tracker: Equatable, Hashable {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: Set<Weekday>
    let categoryName: String?
    let createdAt: Date
    let isPinned: Bool
    
    enum Weekday: Int, CaseIterable {
        case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
    }
}

extension Tracker.Weekday {
    var shortName: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
}
