import UIKit
import CoreData

final class UnscheduledViewController: UIViewController {
    
    var currentDate: Date = Date()
    var trackerToEdit: Tracker?
    weak var delegate: TrackerEditDelegate?
    weak var creationDelegate: NewTrackerDelegate?
    
    // MARK: - Data Sources
    
    private let emojis = [
        "😀", "😅", "😂", "🥲", "😊", "😍", "😎", "🤩",
        "😇", "😴", "😤", "🤯", "😡", "😭", "🙃", "🤔",
        "🙌", "👏", "💪", "🧘‍♂️", "🚴‍♀️", "🏃‍♂️", "🧗‍♀️", "🏋️‍♂️",
        "📚", "🧠", "✍️", "🎧", "🎵", "🎨", "🎮", "📷",
        "🍎", "🍌", "🥦", "🍔", "🍩", "🍕", "☕️", "🧃",
        "🛏", "🧼", "🪥", "🛁", "🌿", "📅", "💰", "❤️"
    ]
    
    private let colors: [UIColor] = [
        UIColor(resource: .ypSelectionBlue), UIColor(resource: .ypSelectionDarkBlue),
        UIColor(resource: .ypSelectionGreen), UIColor(resource: .ypSelectionMagent),
        UIColor(resource: .ypSelectionOrange), UIColor(resource: .ypSelectionPink),
        UIColor(resource: .ypSelectionRed), UIColor(resource: .ypSelectionSandyOrange),
        UIColor(resource: .ypSelectionSoftBlue), UIColor(resource: .ypSelectionSoftGreen),
        UIColor(resource: .ypSelectionSoftIndigo), UIColor(resource: .ypSelectionSoftOrange),
        UIColor(resource: .ypSelectionSoftPink), UIColor(resource: .ypSelectionSoftPurple),
        UIColor(resource: .ypSelectionVividGreen), UIColor(resource: .ypSelectionVividMagent),
        UIColor(resource: .ypSelectionVividPurple), UIColor(resource: .ypSelectionVividViolet)
    ]
    
    private var selectedEmojiIndex: IndexPath?
    private var selectedColorIndex: IndexPath?
    private var selectedCategory: CategoryEntity?
    
    // MARK: - UI
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let buttonsContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let actionButtonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let buttonsWrapperView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypLightGray
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 75).isActive = true
        return view
    }()
    
    private let actionButtonsWrapper: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let newHabitLabel: UILabel = {
        let label = UILabel()
        label.text = "Новое нерегулярное событие"
        label.font = .YPFont(16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .ypWhite
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .ypLightGray
        textField.layer.cornerRadius = 16
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        textField.clearButtonMode = .whileEditing
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 75))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()
    
    private let categoryButton = makeListItem(title: "Категория")
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.backgroundColor = .ypWhite
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.font = .YPFont(16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: Self.makeGridLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseIdentifier)
        
        return collectionView
    }()
    
    private let colorLabel: UILabel = {
        let label = UILabel()
        label.text = "Цвет"
        label.font = .YPFont(16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: Self.makeGridLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseIdentifier)
        return collectionView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkEditMode()
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        categoryButton.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        
        view.addSubview(scrollView)
        view.backgroundColor = .ypWhite
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        scrollView.addSubview(contentView)
        scrollView.backgroundColor = .ypWhite
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        scrollView.keyboardDismissMode = .onDrag
        contentView.backgroundColor = .ypWhite
        setupLayout()
        nameTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(nameTextChanged), for: .editingChanged)
        updateCreateButtonState()
        
    }
    
    // MARK: - Layout
    
    private func makeSpacer(height: CGFloat) -> UIView {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: height).isActive = true
        return spacer
    }
    
    private func makeDivider(inset: CGFloat = 16) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = .separator
        
        container.addSubview(divider)
        
        NSLayoutConstraint.activate([
            divider.topAnchor.constraint(equalTo: container.topAnchor),
            divider.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            divider.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: inset),
            divider.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -inset),
            divider.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        return container
    }
    
    private func updateCreateButtonState() {
        let isFormFilled =
        !(nameTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true) &&
        selectedEmojiIndex != nil &&
        selectedColorIndex != nil &&
        selectedCategory != nil
        
        createButton.isEnabled = isFormFilled
        createButton.backgroundColor = isFormFilled ? .ypBlack : .ypGray
    }
    
    private func setupLayout() {
        
        [
            newHabitLabel,
            makeSpacer(height: 24),
            nameTextField,
            makeSpacer(height: 24),
            buttonsWrapperView,
            makeSpacer(height: 32),
            emojiLabel,
            makeSpacer(height: 1),
            emojiCollectionView,
            makeSpacer(height: 16),
            colorLabel,
            makeSpacer(height: 1),
            colorCollectionView,
            makeSpacer(height: 16),
            actionButtonsWrapper
        ].forEach { stackView.addArrangedSubview($0) }
        
        buttonsContainer.addArrangedSubview(categoryButton)
        buttonsWrapperView.addSubview(buttonsContainer)
        
        actionButtonsStack.addArrangedSubview(cancelButton)
        actionButtonsStack.addArrangedSubview(createButton)
        actionButtonsWrapper.addSubview(actionButtonsStack)
        
        NSLayoutConstraint.activate([
            buttonsContainer.topAnchor.constraint(equalTo: buttonsWrapperView.topAnchor),
            buttonsContainer.bottomAnchor.constraint(equalTo: buttonsWrapperView.bottomAnchor),
            buttonsContainer.leadingAnchor.constraint(equalTo: buttonsWrapperView.leadingAnchor),
            buttonsContainer.trailingAnchor.constraint(equalTo: buttonsWrapperView.trailingAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            
            actionButtonsStack.topAnchor.constraint(equalTo: actionButtonsWrapper.topAnchor),
            actionButtonsStack.bottomAnchor.constraint(equalTo: actionButtonsWrapper.bottomAnchor),
            actionButtonsStack.leadingAnchor.constraint(equalTo: actionButtonsWrapper.leadingAnchor),
            actionButtonsStack.trailingAnchor.constraint(equalTo: actionButtonsWrapper.trailingAnchor),
            actionButtonsWrapper.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        emojiCollectionView.heightAnchor.constraint(equalToConstant: 176).isActive = true
        colorCollectionView.heightAnchor.constraint(equalToConstant: 176).isActive = true
        
        let heightConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor)
        heightConstraint.priority = .defaultLow
        heightConstraint.isActive = true
        
    }
    
    // MARK: - Helpers
    
    @objc private func cancelButtonTapped() {
        AnimationHelper.animateButtonPress(cancelButton) { [weak self] in
            guard let self else { return }
            
            if trackerToEdit != nil {
                self.dismiss(animated: true)
            } else {
                self.presentingViewController?.presentingViewController?.dismiss(animated: true)
            }
        }
    }
    @objc private func createButtonTapped() {
        AnimationHelper.animateButtonPress(createButton) { [self] in
            guard
                let name = nameTextField.text,
                let selectedEmojiIndex,
                let selectedColorIndex,
                let selectedCategory
            else { return }
            
            if let existing = trackerToEdit {
                let updated = Tracker(
                    id: existing.id,
                    title: name,
                    color: colors[selectedColorIndex.item],
                    emoji: emojis[selectedEmojiIndex.item],
                    schedule: [],
                    categoryName: selectedCategory.name ?? "",
                    createdAt: existing.createdAt,
                    isPinned: existing.isPinned
                )
                
                TrackerStore.shared.updateTracker(updated, categoryTitle: selectedCategory.name ?? "")
                delegate?.didUpdateTracker(updated)
            } else {
                let newTracker = Tracker(
                    id: UUID(),
                    title: name,
                    color: colors[selectedColorIndex.item],
                    emoji: emojis[selectedEmojiIndex.item],
                    schedule: [],
                    categoryName: selectedCategory.name ?? "",
                    createdAt: currentDate,
                    isPinned: false
                )
                
                TrackerStore.shared.addTracker(newTracker, categoryTitle: selectedCategory.name ?? "", createdAt: currentDate)
            }
            
            if trackerToEdit != nil {
                self.dismiss(animated: true)
            } else {
                creationDelegate?.didCreateNewTracker()
                self.presentingViewController?.presentingViewController?.dismiss(animated: true)
            }
        }
    }
    
    @objc private func categoryButtonTapped() {
        AnimationHelper.animateButtonPress(categoryButton) { [weak self] in
            guard let self = self else { return }
            
            let categoryVC = CategoryViewController()
            categoryVC.delegate = self
            
            let navController = UINavigationController(rootViewController: categoryVC)
            navController.modalPresentationStyle = .pageSheet
            self.present(navController, animated: true)
        }
    }
    
    @objc private func nameTextChanged() {
        updateCreateButtonState()
    }
    
    private func checkEditMode() {
        guard let tracker = trackerToEdit else { return }

        newHabitLabel.text = "Редактировать событие"
        nameTextField.text = tracker.title

        if let emojiIndex = emojis.firstIndex(of: tracker.emoji) {
            selectedEmojiIndex = IndexPath(item: emojiIndex, section: 0)
        }

        if let colorIndex = colors.firstIndex(where: { hexString(from: $0) == hexString(from: tracker.color) }) {
            selectedColorIndex = IndexPath(item: colorIndex, section: 0)
        }

        selectedCategory = CoreDataManager.shared.context
            .registeredObjects
            .compactMap { $0 as? CategoryEntity }
            .first { $0.name == tracker.categoryName }
        updateCategoryButtonSubtitle()

        createButton.setTitle("Сохранить", for: .normal)

        emojiCollectionView.reloadData()
        colorCollectionView.reloadData()
    }
    
    private static func makeListItem(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = .YPFont(16, weight: .regular)
        button.backgroundColor = .ypLightGray
        button.layer.masksToBounds = true
        button.heightAnchor.constraint(equalToConstant: 75).isActive = true
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 40)
        
        let arrowImage = UIImage(systemName: "chevron.right")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        let arrowImageView = UIImageView(image: arrowImage)
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(arrowImageView)
        
        NSLayoutConstraint.activate([
            arrowImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16)
        ])

        button.layer.cornerRadius = 16
        return button
    }
    
    private static func makeGridLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: 52, height: 52)
        return layout
    }
}

// MARK: - UICollectionViewDataSource

extension UnscheduledViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == emojiCollectionView ? emojis.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.reuseIdentifier, for: indexPath) as! EmojiCell
            cell.configure(with: emojis[indexPath.item], selected: indexPath == selectedEmojiIndex)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.reuseIdentifier, for: indexPath) as! ColorCell
            cell.configure(with: colors[indexPath.item], selected: indexPath == selectedColorIndex)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmojiIndex = indexPath
            emojiCollectionView.reloadData()
        } else if collectionView == colorCollectionView {
            selectedColorIndex = indexPath
            colorCollectionView.reloadData()
        }
        updateCreateButtonState()
    }
}

// MARK: - Extensions

extension UnscheduledViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text,
              let rangeInText = Range(range, in: currentText) else {
            return true
        }
        
        let updatedText = currentText.replacingCharacters(in: rangeInText, with: string)
        
        if updatedText.count > 38 {
            showLengthExceededAlert()
            return false
        }
        
        return true
    }
    
    private func showLengthExceededAlert() {
        let alert = UIAlertController(title: nil, message: "Достигнут лимит ввода символов", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
    
}

extension UnscheduledViewController: CategorySelectionDelegate {
    func didSelectCategory(_ category: CategoryEntity) {
        selectedCategory = category
        updateCategoryButtonSubtitle()
        updateCreateButtonState()
    }
    
    private func updateCategoryButtonSubtitle() {
        let title = "Категория"
        let subtitle = selectedCategory?.name ?? "Не выбрано"
        
        let fullText = "\(title)\n\(subtitle)"
        let attributedText = NSMutableAttributedString(string: fullText)
        
        attributedText.addAttribute(.font,
                                    value: UIFont.YPFont(16, weight: .regular),
                                    range: (fullText as NSString).range(of: title))
        
        attributedText.addAttribute(.font,
                                    value: UIFont.YPFont(14, weight: .regular),
                                    range: (fullText as NSString).range(of: subtitle))
        
        attributedText.addAttribute(.foregroundColor,
                                    value: UIColor.ypGray,
                                    range: (fullText as NSString).range(of: subtitle))
        
        categoryButton.setAttributedTitle(attributedText, for: .normal)
        categoryButton.titleLabel?.numberOfLines = 2
    }
}


