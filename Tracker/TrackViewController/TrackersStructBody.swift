import UIKit

struct Tracker: Equatable, Hashable {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: Set<Weekday>
    
    enum Weekday: Int, CaseIterable {
        case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
    }
}

struct TrackerCategory: Hashable {
    let title: String
    let trackers: [Tracker]

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }

    static func == (lhs: TrackerCategory, rhs: TrackerCategory) -> Bool {
        lhs.title == rhs.title
    }
}


struct TrackerRecord: Equatable, Hashable {
    let id: UUID      // ID трекера
    let date: Date    // дата выполнения
}
