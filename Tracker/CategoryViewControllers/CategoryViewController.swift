import UIKit
import CoreData

protocol CategorySelectionDelegate: AnyObject {
    func didSelectCategory(_ category: CategoryEntity)
}


final class CategoryViewController: UIViewController {
    
    weak var delegate: CategorySelectionDelegate?

    private var categories: [CategoryEntity] = []

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = .YPFont(16, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .starRing)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .ypBlack
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let categoriesContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .ypLightGray
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let categoriesStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupLayout()
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)

        resetCategorySelection()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCategories()
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(emptyImageView)
        view.addSubview(descriptionLabel)
        view.addSubview(addButton)
        view.addSubview(categoriesContainer)
        categoriesContainer.addSubview(categoriesStack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 78),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),

            descriptionLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 8),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 60),

            categoriesContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            categoriesContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categoriesContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            categoriesContainer.bottomAnchor.constraint(lessThanOrEqualTo: addButton.topAnchor, constant: -16),

            categoriesStack.topAnchor.constraint(equalTo: categoriesContainer.topAnchor, constant: 16),
            categoriesStack.bottomAnchor.constraint(equalTo: categoriesContainer.bottomAnchor, constant: -16),
            categoriesStack.leadingAnchor.constraint(equalTo: categoriesContainer.leadingAnchor, constant: 16),
            categoriesStack.trailingAnchor.constraint(equalTo: categoriesContainer.trailingAnchor, constant: -16)
        ])
    }

    // MARK: - Helpers
    private func resetCategorySelection() {
        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        if let all = try? CoreDataManager.shared.context.fetch(request) {
            for category in all {
                category.isSelected = false
            }
            CoreDataManager.shared.saveContext()
        }
    }

    private func fetchCategories() {
        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        categories = (try? CoreDataManager.shared.context.fetch(request)) ?? []

        let hasCategories = !categories.isEmpty
        categoriesContainer.isHidden = !hasCategories
        emptyImageView.isHidden = hasCategories
        descriptionLabel.isHidden = hasCategories

        categoriesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, category) in categories.enumerated() {
            let row = makeCategoryRow(for: category, index: index)
            categoriesStack.addArrangedSubview(row)

            if index < categories.count - 1 {
                categoriesStack.addArrangedSubview(makeDivider())
            }
        }
    }

    private func makeCategoryRow(for category: CategoryEntity, index: Int) -> UIView {
        let label = UILabel()
        label.text = category.name
        label.font = .YPFont(17, weight: .regular)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false

        let checkmark = UIImageView()
        checkmark.image = category.isSelected ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
        checkmark.tintColor = .ypBlue
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        checkmark.setContentHuggingPriority(.required, for: .horizontal)

        let rowStack = UIStackView(arrangedSubviews: [label, checkmark])
        rowStack.axis = .horizontal
        rowStack.alignment = .center
        rowStack.distribution = .fill
        rowStack.spacing = 8
        rowStack.translatesAutoresizingMaskIntoConstraints = false

        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(rowStack)

        NSLayoutConstraint.activate([
            rowStack.topAnchor.constraint(equalTo: wrapper.topAnchor),
            rowStack.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            rowStack.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            rowStack.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            wrapper.heightAnchor.constraint(equalToConstant: 75)
        ])

        wrapper.tag = index

        // tap = выбор категории
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(categoryTapped(_:)))
        wrapper.addGestureRecognizer(tapGesture)

        // long press = меню
        let interaction = UIContextMenuInteraction(delegate: self)
        wrapper.addInteraction(interaction)

        return wrapper
    }



    private func makeDivider(inset: CGFloat = 0) -> UIView {
        let divider = UIView()
        divider.backgroundColor = .separator
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return divider
    }

    // MARK: - Actions

    @objc private func categoryTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag else { return }

        for (i, cat) in categories.enumerated() {
            cat.isSelected = (i == index)
        }

        CoreDataManager.shared.saveContext()
        fetchCategories()

        delegate?.didSelectCategory(categories[index])
        navigationController?.popViewController(animated: true)
    }


    @objc private func addButtonTapped() {
        AnimationHelper.animateButtonPress(addButton) { [weak self] in
            let newCategoryVC = NewCategoryViewController()
            self?.navigationController?.pushViewController(newCategoryVC, animated: true)
        }
    }
}

extension CategoryViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let wrapperView = interaction.view,
              wrapperView.tag < categories.count else { return nil }

        let category = categories[wrapperView.tag]

        return UIContextMenuConfiguration(identifier: wrapperView.tag as NSCopying, previewProvider: nil) { _ in
            let edit = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { [weak self] _ in
                self?.editCategory(category)
            }

            let delete = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                self?.confirmDeleteCategory(category)
            }

            return UIMenu(title: "", children: [edit, delete])
        }
    }
    
    private func editCategory(_ category: CategoryEntity) {
        let editVC = NewCategoryViewController()
        editVC.configure(with: category)
        navigationController?.pushViewController(editVC, animated: true)
    }

    private func confirmDeleteCategory(_ category: CategoryEntity) {
        let alert = UIAlertController(
            title: "Удалить категорию?",
            message: "Это действие нельзя отменить.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            CoreDataManager.shared.context.delete(category)
            CoreDataManager.shared.saveContext()
            self.fetchCategories()
        })
        
        present(alert, animated: true)
    }


}

