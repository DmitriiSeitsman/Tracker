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
