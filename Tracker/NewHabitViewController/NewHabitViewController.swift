import UIKit
import CoreData

final class NewHabitViewController: UIViewController {
    
    var currentDate = Date()
    var completedDays: Int?
    var trackerToEdit: Tracker?
    weak var delegate: TrackerEditDelegate?
    weak var creationDelegate: NewTrackerDelegate?
    
    
    // MARK: - Data Sources
    
    private let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶",
        "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
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
    private var selectedCategory: CategoryCoreData?
    private var selectedWeekdays: Set<Tracker.Weekday> = []
    private var collectionViewHeightConstraint: NSLayoutConstraint?
    
    
    
    // MARK: - UI
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .ypWhite
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ypWhite
        return view
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .ypBackgroundDay.withAlphaComponent(0.3)
        textField.layer.cornerRadius = 16
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        textField.addTarget(self, action: #selector(nameTextChanged), for: .editingChanged)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 75))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()
    
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
        view.backgroundColor = .ypBackgroundDay.withAlphaComponent(0.3)
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 151).isActive = true
        return view
    }()
    
    private let actionButtonsWrapper: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypRed
        label.font = .YPFont(17, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let daysCounterLabel: UILabel = {
        let label = UILabel()
        label.font = .YPFont(32, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoryButton = makeListItem(title: "Категория", isUp: true)
    private let scheduleButton = makeListItem(title: "Расписание", isUp: false)
    
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
    
    private lazy var collectionView: UICollectionView = {
        let layout = TrackerLayoutFactory.createLayout()
        let collectionView = IntrinsicCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBarTitle()
        checkEditMode()
        addTargets()
        daysCounterLabel.isHidden = true
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseIdentifier)
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseIdentifier)
        collectionView.register(TrackerHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TrackerHeaderView.reuseIdentifier)
        
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
        setupTapToDismissKeyboard()
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
    
    private func configureNavigationBarTitle() {
        guard navigationController != nil else { return }
        
        let titleFont = UIFont.YPFont(16, weight: .medium)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypWhite
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: titleFont
        ]
        appearance.shadowColor = .clear
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.title = trackerToEdit == nil ? "Новая привычка" : "Редактировать привычку"
    }
    
    private func updateCreateButtonState() {
        let isFormFilled =
        !(nameTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true) &&
        selectedEmojiIndex != nil &&
        selectedColorIndex != nil &&
        selectedCategory != nil &&
        !selectedWeekdays.isEmpty
        
        createButton.isEnabled = isFormFilled
        createButton.backgroundColor = isFormFilled ? .ypBlack : .ypGray
    }
    
    private func setupLayout() {
        
        [
            daysCounterLabel,
            makeSpacer(height: 24),
            nameTextField,
            errorLabel,
            makeSpacer(height: 24),
            buttonsWrapperView,
            makeSpacer(height: 32),
            collectionView,
            makeSpacer(height: 16),
            actionButtonsWrapper
        ].forEach { stackView.addArrangedSubview($0) }
        
        collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 100)
        collectionViewHeightConstraint?.isActive = true
        
        buttonsContainer.addArrangedSubview(categoryButton)
        buttonsContainer.addArrangedSubview(makeDivider())
        buttonsContainer.addArrangedSubview(scheduleButton)
        buttonsWrapperView.addSubview(buttonsContainer)
        
        actionButtonsStack.addArrangedSubview(cancelButton)
        actionButtonsStack.addArrangedSubview(createButton)
        actionButtonsWrapper.addSubview(actionButtonsStack)
        
        NSLayoutConstraint.activate([
            buttonsContainer.topAnchor.constraint(equalTo: buttonsWrapperView.topAnchor),
            buttonsContainer.bottomAnchor.constraint(equalTo: buttonsWrapperView.bottomAnchor),
            buttonsContainer.leadingAnchor.constraint(equalTo: buttonsWrapperView.leadingAnchor),
            buttonsContainer.trailingAnchor.constraint(equalTo: buttonsWrapperView.trailingAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            
            actionButtonsStack.topAnchor.constraint(equalTo: actionButtonsWrapper.topAnchor),
            actionButtonsStack.bottomAnchor.constraint(equalTo: actionButtonsWrapper.bottomAnchor),
            actionButtonsStack.leadingAnchor.constraint(equalTo: actionButtonsWrapper.leadingAnchor),
            actionButtonsStack.trailingAnchor.constraint(equalTo: actionButtonsWrapper.trailingAnchor),
            actionButtonsWrapper.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        let heightConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor)
        heightConstraint.priority = .defaultLow
        heightConstraint.isActive = true
        
    }
    
    private func setupTapToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // чтобы не ломать тап по кнопкам и ячейкам
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.layoutIfNeeded()

        let height = collectionView.collectionViewLayout.collectionViewContentSize.height
        collectionViewHeightConstraint?.constant = height
    }

    
    // MARK: - Helpers
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
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
                let selectedCategory,
                !selectedWeekdays.isEmpty
            else { return }
            
            if let existing = trackerToEdit {
                let updated = Tracker(
                    id: existing.id,
                    title: name,
                    color: colors[selectedColorIndex.item],
                    emoji: emojis[selectedEmojiIndex.item],
                    schedule: selectedWeekdays,
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
                    schedule: selectedWeekdays,
                    categoryName: selectedCategory.name ?? "",
                    createdAt: currentDate,
                    isPinned: false
                )
                
                TrackerStore.shared.addTracker(newTracker, categoryTitle: selectedCategory.name ?? "", createdAt: Date())
            }
            
            if trackerToEdit != nil {
                self.creationDelegate?.didCreateNewTracker()
                self.dismiss(animated: true) {
                }
            } else {
                self.creationDelegate?.didCreateNewTracker()
                self.presentingViewController?.presentingViewController?.dismiss(animated: true) {
                }
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
    
    @objc private func scheduleButtonTapped() {
        AnimationHelper.animateButtonPress(scheduleButton) { [weak self] in
            self?.presentDaysSelection()
        }
    }
    
    @objc private func nameTextChanged() {
        updateCreateButtonState()
    }
    
    private func addTargets() {
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        scheduleButton.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
        categoryButton.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
    }
    
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
        ])
        nameTextField.layer.borderColor = UIColor.systemRed.cgColor
        nameTextField.layer.borderWidth = 1
    }
    
    private func hideError() {
        errorLabel.isHidden = true
        errorLabel.text = nil
        nameTextField.layer.borderWidth = 0
    }
    
    private func checkEditMode() {
        guard let tracker = trackerToEdit else { return }
        
        nameTextField.text = tracker.title
        
        if let emojiIndex = emojis.firstIndex(of: tracker.emoji) {
            selectedEmojiIndex = IndexPath(item: emojiIndex, section: 0)
        }
        
        if let colorIndex = colors.firstIndex(where: { hexString(from: $0) == hexString(from: tracker.color) }) {
            selectedColorIndex = IndexPath(item: colorIndex, section: 0)
        }
        
        if let days = completedDays {
            daysCounterLabel.text = "\(days) \(daysWord(for: days))"
            daysCounterLabel.isHidden = false
        }
        
        selectedWeekdays = tracker.schedule
        updateScheduleButtonSubtitle()
        
        selectedCategory = CoreDataManager.shared.context
            .registeredObjects
            .compactMap { $0 as? CategoryCoreData }
            .first { $0.name == tracker.categoryName }
        updateCategoryButtonSubtitle()
        
        createButton.setTitle("Сохранить", for: .normal)
    }
    
    private func presentDaysSelection() {
        let vc = DaysSelectionViewController()
        vc.delegate = self
        vc.configure(with: selectedWeekdays)
        
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .pageSheet
        
        present(navController, animated: true)
    }
    
    private static func makeListItem(title: String, isUp: Bool) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = .YPFont(17, weight: .regular)
        button.backgroundColor = .clear
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
        if isUp {
            button.layer.cornerRadius = 16
            button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            return button
        }
        button.layer.cornerRadius = 16
        button.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
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

extension NewHabitViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2 // 0 — Emoji, 1 — Color
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? emojis.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.reuseIdentifier, for: indexPath) as! EmojiCell
            cell.configure(with: emojis[indexPath.item], selected: indexPath == selectedEmojiIndex)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.reuseIdentifier, for: indexPath) as! ColorCell
            cell.configure(with: colors[indexPath.item], selected: indexPath == selectedColorIndex)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerHeaderView.reuseIdentifier,
            for: indexPath
        ) as! TrackerHeaderView
        
        let title = indexPath.section == 0 ? "Emoji" : "Цвет"
        header.configure(with: title)
        
        return header
    }
}

extension NewHabitViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            
            let previous = selectedEmojiIndex
            selectedEmojiIndex = indexPath
            
            var indexPathsToReload: [IndexPath] = [indexPath]
            if let previous, previous != indexPath {
                indexPathsToReload.append(previous)
            }
            
            collectionView.reloadItems(at: indexPathsToReload)
            
        } else if indexPath.section == 1 {
            let previous = selectedColorIndex
            selectedColorIndex = indexPath
            
            var indexPathsToReload: [IndexPath] = [indexPath]
            if let previous, previous != indexPath {
                indexPathsToReload.append(previous)
            }
            
            collectionView.reloadItems(at: indexPathsToReload)
        }
        
        updateCreateButtonState()
    }
    
}

// MARK: - Extensions

extension NewHabitViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text,
              let rangeInText = Range(range, in: currentText) else {
            return true
        }
        
        let updatedText = currentText.replacingCharacters(in: rangeInText, with: string)
        
        if updatedText.count > 38 {
            showError("Ограничение 38 символов")
            return false
        }
        hideError()
        return true
    }
    
}

extension NewHabitViewController: DaysSelectionViewControllerDelegate {
    func didSelectWeekdays(_ weekdays: Set<Tracker.Weekday>) {
        selectedWeekdays = weekdays
        updateScheduleButtonSubtitle()
        updateCreateButtonState()
    }
    
    private func updateScheduleButtonSubtitle() {
        let isEveryDay = selectedWeekdays.count == 7
        
        let subtitle = isEveryDay
        ? "Каждый день"
        : selectedWeekdays
            .sorted { $0.rawValue < $1.rawValue }
            .map { $0.shortName }
            .joined(separator: ", ")
        
        let title = "Расписание"
        let fullText = "\(title)\n\(subtitle)"
        let attributedText = NSMutableAttributedString(string: fullText)
        
        attributedText.addAttribute(.font,
                                    value: UIFont.YPFont(17, weight: .regular),
                                    range: (fullText as NSString).range(of: title))
        
        attributedText.addAttribute(.font,
                                    value: UIFont.YPFont(17, weight: .regular),
                                    range: (fullText as NSString).range(of: subtitle))
        
        attributedText.addAttribute(.foregroundColor,
                                    value: UIColor.ypGray,
                                    range: (fullText as NSString).range(of: subtitle))
        
        scheduleButton.setAttributedTitle(attributedText, for: .normal)
        scheduleButton.titleLabel?.numberOfLines = 2
    }
    
    
}

extension NewHabitViewController: CategorySelectionDelegate {
    func didSelectCategory(_ category: CategoryCoreData) {
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
                                    value: UIFont.YPFont(17, weight: .regular),
                                    range: (fullText as NSString).range(of: title))
        
        attributedText.addAttribute(.font,
                                    value: UIFont.YPFont(17, weight: .regular),
                                    range: (fullText as NSString).range(of: subtitle))
        
        attributedText.addAttribute(.foregroundColor,
                                    value: UIColor.ypGray,
                                    range: (fullText as NSString).range(of: subtitle))
        
        categoryButton.setAttributedTitle(attributedText, for: .normal)
        categoryButton.titleLabel?.numberOfLines = 2
    }
}

