import UIKit

final class NewCategoryViewController: UIViewController {
    
    private var editingCategory: CategoryEntity?

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
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
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        textField.textColor = .ypBlack
        textField.font = .systemFont(ofSize: 17)
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
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupLayout()

        navigationItem.hidesBackButton = true

        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }


    // MARK: - Layout

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

    // MARK: - Logic
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        let isValid = !(textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        createButton.isEnabled = isValid
        createButton.backgroundColor = isValid ? .ypBlack : .ypGray
    }

    @objc private func createTapped() {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespaces), !name.isEmpty else { return }

        AnimationHelper.animateButtonPress(createButton) {
            if let category = self.editingCategory {
                // Режим редактирования
                category.name = name
            } else {
                // Режим создания
                let newCategory = CategoryEntity(context: CoreDataManager.shared.context)
                newCategory.name = name
                newCategory.isSelected = false
            }

            CoreDataManager.shared.saveContext()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func configure(with category: CategoryEntity) {
        editingCategory = category
        nameTextField.text = category.name
        textFieldDidChange(nameTextField)
        titleLabel.text = "Редактирование категории"
    }

}
