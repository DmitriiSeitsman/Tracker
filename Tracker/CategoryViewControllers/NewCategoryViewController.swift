import UIKit
import CoreData

final class NewCategoryViewController: UIViewController {

    // MARK: - Properties

    private var editingCategory: CategoryEntity?

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .YPFont(16, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.backgroundColor = .ypLightGray
        textField.layer.cornerRadius = 16
        textField.textColor = .ypBlack
        textField.font = .systemFont(ofSize: 17)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 75).isActive = true

        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 75))
        textField.leftView = padding
        textField.leftViewMode = .always

        return textField
    }()

    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .ypGray
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        navigationItem.hidesBackButton = true

        setupLayout()
        setupActions()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUIIfEditing()
    }

    // MARK: - Setup

    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(nameTextField)
        view.addSubview(createButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 78),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func setupActions() {
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
    }

    private func updateUIIfEditing() {
        if let category = editingCategory {
            titleLabel.text = "Редактирование категории"
            nameTextField.text = category.name
            textFieldDidChange(nameTextField)
        } else {
            titleLabel.text = "Новая категория"
        }
    }

    // MARK: - Actions

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        let isValid = !(textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        createButton.isEnabled = isValid
        createButton.backgroundColor = isValid ? .ypBlack : .ypGray
    }

    @objc private func createTapped() {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            return
        }

        AnimationHelper.animateButtonPress(createButton) {
            let context = CoreDataManager.shared.context

            if self.editingCategory == nil {
                // Check for duplicates
                let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
                request.predicate = NSPredicate(format: "name == %@", name)
                let existing = (try? context.fetch(request)) ?? []
                if !existing.isEmpty {
                    self.showDuplicateAlert()
                    return
                }
            }

            let category = self.editingCategory ?? CategoryEntity(context: context)
            category.name = name
            category.isSelected = false

            CoreDataManager.shared.saveContext()
            self.navigationController?.popViewController(animated: true)
        }
    }

    private func showDuplicateAlert() {
        let alert = UIAlertController(title: "Категория уже существует", message: "Введите другое название.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }

    // MARK: - External Configuration

    func configure(with category: CategoryEntity) {
        editingCategory = category
    }
}
