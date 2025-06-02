import UIKit
import CoreData

protocol CategorySelectionDelegate: AnyObject {
    func didSelectCategory(_ category: CategoryEntity)
}


final class CategoryViewController: UIViewController {
    
    weak var delegate: CategorySelectionDelegate?
    
    private var categories: [CategoryEntity] = []
    
    // MARK: - UI
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .ypLightGray
        table.separatorStyle = .singleLine
        table.layer.cornerRadius = 16
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.showsVerticalScrollIndicator = false
        return table
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
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseId)
        
        setupLayout()
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCategories()
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
        configureNavigationBar()
        view.addSubview(emptyImageView)
        view.addSubview(descriptionLabel)
        view.addSubview(addButton)
        view.addSubview(tableView)
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            
            descriptionLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 8),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    // MARK: - Helpers
    
    private func fetchCategories() {
        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        categories = (try? CoreDataManager.shared.context.fetch(request)) ?? []
        
        let hasCategories = !categories.isEmpty
        tableView.isHidden = !hasCategories
        emptyImageView.isHidden = hasCategories
        descriptionLabel.isHidden = hasCategories
        
        let rowHeight: CGFloat = 75
        let totalHeight = CGFloat(categories.count) * rowHeight
        tableViewHeightConstraint?.constant = totalHeight
        
        tableView.reloadData()
    }
    
    private func configureNavigationBar() {
        title = "Категория"
        
        guard let navBar = navigationController?.navigationBar else { return }
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypWhite
        appearance.shadowColor = nil // Убираем разделитель
        
        appearance.titleTextAttributes = [
            .font: UIFont.YPFont(16, weight: .medium),
            .foregroundColor: UIColor.ypBlack
        ]
        
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
    }
    
    // MARK: - Actions
    
    @objc private func addButtonTapped() {
        AnimationHelper.animateButtonPress(addButton) { [weak self] in
            let newCategoryVC = NewCategoryViewController()
            self?.navigationController?.pushViewController(newCategoryVC, animated: true)
        }
    }
}

extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = categories[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseId, for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        
        cell.titleLabel.text = category.name
        cell.accessoryType = category.isSelected ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for (i, cat) in categories.enumerated() {
            cat.isSelected = (i == indexPath.row)
        }
        
        CoreDataManager.shared.saveContext()
        tableView.reloadData()
        
        delegate?.didSelectCategory(categories[indexPath.row])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let nav = self.navigationController, nav.viewControllers.first == self {
                self.dismiss(animated: true)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let category = categories[indexPath.row]
        
        let editAction = UIContextualAction(style: .normal, title: "Редактировать") { [weak self] _, _, done in
            self?.editCategory(category)
            done(true)
        }
        editAction.backgroundColor = .systemBlue
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, done in
            self?.confirmDeleteCategory(category)
            done(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        let category = categories[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { _ in
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

