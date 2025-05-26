import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()

    private init() {}

    lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerInfo")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("❌ Core Data error: \(error)")
            }
        }
        return container
    }()

    func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }
}
