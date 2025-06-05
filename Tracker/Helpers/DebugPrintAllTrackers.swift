import CoreData

func debugPrintAllTrackers() {
    let request: NSFetchRequest<TrackerEntity> = TrackerEntity.fetchRequest()
    let entities = (try? CoreDataManager.shared.context.fetch(request)) ?? []
    
    print("=== Трекеры в базе ===")
    for tracker in entities {
        let title = tracker.title ?? "—"
        let category = tracker.category?.name ?? "❌ без категории"
        
        var scheduleText = "—"
        if let data = tracker.schedule,
           let rawValues = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data) as? [NSNumber] {
            
            let weekdays = rawValues.compactMap { Tracker.Weekday(rawValue: $0.intValue) }
            let shortNames = weekdays.map { $0.shortName }.joined(separator: ", ")
            if !shortNames.isEmpty {
                scheduleText = shortNames
            }
        }

        print("📌 \(title) | \(category) | \(scheduleText)")
    }
}
