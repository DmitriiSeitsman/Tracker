import CoreData

final class CategoryViewModel {
    
    var bindCategories: (([CategoryCoreData]) -> Void)?
    var hasCategories: Bool {
        !categories.isEmpty
    }
    private(set) var categories: [CategoryCoreData] = [] {
        didSet {
            bindCategories?(categories)
        }
    }
    
    func fetchCategories() {
        let request: NSFetchRequest<CategoryCoreData> = CategoryCoreData.fetchRequest()
        categories = (try? CoreDataManager.shared.context.fetch(request)) ?? []
    }
    
    func selectCategory(at index: Int) {
        for (i, category) in categories.enumerated() {
            category.isSelected = (i == index)
        }
        CoreDataManager.shared.saveContext()
        fetchCategories()
    }
    
    func deleteCategory(at index: Int) {
        let category = categories[index]
        CoreDataManager.shared.context.delete(category)
        CoreDataManager.shared.saveContext()
        fetchCategories()
    }
}
