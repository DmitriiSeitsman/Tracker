//import UIKit
//
//final class TrackersViewController : UIViewController {
//    
//    var categories: [TrackerCategory] = []
//    var completedTrackers: [TrackerRecord] = []
//    var currentDate: Date = Date()
//    
//    private let titleLabel = UILabel()
//    private let searchBar = UISearchBar()
//    private let placeholderImageView = UIImageView()
//    private let placeholderLabel = UILabel()
//    private var collectionView: UICollectionView!
//    private var dataSource: UICollectionViewDiffableDataSource<TrackerCategory, Tracker>!
//
//    private lazy var datePicker: UIDatePicker = {
//        let picker = UIDatePicker()
//        picker.datePickerMode = .date
//        picker.preferredDatePickerStyle = .compact
//        picker.locale = Locale(identifier: "ru_RU")
//        picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
//        return picker
//    }()
//    
//    private lazy var addTrackerButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setImage(UIImage(resource: .addTracker), for: .normal)
//        button.tintColor = .label
//        button.frame = CGRect(x: 0, y: 0, width: 42, height: 42)
//        button.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
//        return button
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
//        view.backgroundColor = .ypWhite
//        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        tapGesture.cancelsTouchesInView = false
//        view.addGestureRecognizer(tapGesture)
//        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addTrackerButton)
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
//        
//        setupUI()
//        setupCollectionView()
//        setupConstraints()
//        configureDataSource()
//        categories = TrackerStore.shared.fetchAllCategories()
//        applyFilteredSnapshot()
//        
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        categories = TrackerStore.shared.fetchAllCategories()
//        applyFilteredSnapshot()
//    }
//
//    
//    @objc private func dateChanged(_ sender: UIDatePicker) {
//        currentDate = sender.date
//        applyFilteredSnapshot()
//    }
//
//    
//    
//    func addTracker(_ tracker: Tracker, to categoryTitle: String) {
//        let newCategories = categories.map { category in
//            if category.title == categoryTitle {
//                return TrackerCategory(title: category.title, trackers: category.trackers + [tracker])
//            } else {
//                return category
//            }
//        }
//        categories = newCategories
//    }
//    
//    func markTrackerCompleted(_ trackerID: UUID, date: Date) {
//        let record = TrackerRecord(id: trackerID, date: date)
//        completedTrackers.append(record)
//    }
//    
//    func unmarkTracker(_ trackerID: UUID, date: Date) {
//        completedTrackers.removeAll { $0.id == trackerID && Calendar.current.isDate($0.date, inSameDayAs: date) }
//    }
//    
//    
//    @objc private func didTapAdd() {
//        print("➕ Add tapped")
//        let vc = TrackerTypeViewController()
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
//    }
//    
//    private func setupUI() {
//        
//        titleLabel.text = "Трекеры"
//        titleLabel.font = .YPFont(34, weight: .bold)
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(titleLabel)
//        
//        searchBar.placeholder = "Поиск"
//        searchBar.searchTextField.font = .YPFont(17, weight: .regular)
//        searchBar.searchTextField.textColor = .ypGray
//        searchBar.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(searchBar)
//        
//        placeholderImageView.image = UIImage(resource: .starRing)
//        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(placeholderImageView)
//        
//        placeholderLabel.text = "Что будем отслеживать?"
//        placeholderLabel.font = .YPFont(12, weight: .medium)
//        placeholderLabel.textColor = .ypBlack
//        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(placeholderLabel)
//    }
//    
//    private func configureDataSource() {
//        dataSource = UICollectionViewDiffableDataSource<TrackerCategory, Tracker>(collectionView: collectionView) {
//            (collectionView, indexPath, tracker) -> UICollectionViewCell? in
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackerCell else {
//                return nil
//            }
//            cell.configure(with: tracker)
//            return cell
//        }
//
//        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
//            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
//
//            let header = collectionView.dequeueReusableSupplementaryView(
//                ofKind: kind,
//                withReuseIdentifier: "HeaderView",
//                for: indexPath
//            ) as? HeaderView
//
//            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
//            header?.configure(with: section.title)
//            return header
//        }
//    }
//
//    private func applyFilteredSnapshot() {
//        let weekday = Calendar.current.component(.weekday, from: currentDate)
//        guard let selectedWeekday = Tracker.Weekday(rawValue: weekday) else { return }
//
//        var filteredCategories: [TrackerCategory] = []
//
//        for category in categories {
//            let trackersForDay = category.trackers.filter { $0.schedule.contains(selectedWeekday) }
//            if !trackersForDay.isEmpty {
//                filteredCategories.append(TrackerCategory(title: category.title, trackers: trackersForDay))
//            }
//        }
//
//        placeholderImageView.isHidden = !filteredCategories.isEmpty
//        placeholderLabel.isHidden = !filteredCategories.isEmpty
//
//        var snapshot = NSDiffableDataSourceSnapshot<TrackerCategory, Tracker>()
//        for category in filteredCategories {
//            snapshot.appendSections([category])
//            snapshot.appendItems(category.trackers, toSection: category)
//        }
//        dataSource.apply(snapshot, animatingDifferences: true)
//    }
//
//
//    
//    private func setupCollectionView() {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        layout.minimumLineSpacing = 16
//        layout.minimumInteritemSpacing = 8
//        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
//
//        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.backgroundColor = .clear
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.delegate = self
//        view.addSubview(collectionView)
//
//        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
//        collectionView.register(HeaderView.self,
//                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
//                                withReuseIdentifier: "HeaderView")
//        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//        }
//
//    }
//
//    
//    @objc private func dismissKeyboard() {
//        view.endEditing(true)
//    }
//    
//    private func setupConstraints() {
//        NSLayoutConstraint.activate([
//            // "Трекеры"
//            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
//            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            
//            // Поиск
//            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
//            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            
//            // Иконка заглушки
//            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
//            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
//            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
//            
//            // Подпись под иконкой
//            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 12),
//            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            
//            //Ячейки
//            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
//            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//
//        ])
//    }
//    
//}
//
//extension TrackersViewController: UICollectionViewDelegate {
//    // обработка выделения и т.п.
//}
//
//
import UIKit

final class TrackersViewController: UIViewController {

    var categories: [TrackerCategory] = []
    var currentDate: Date = Date()
    
    private var sectionDataSources: [UICollectionViewDataSource] = []

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let titleLabel = UILabel()
    private let searchBar = UISearchBar()
    private let placeholderImageView = UIImageView()
    private let placeholderLabel = UILabel()

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")
        picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        return picker
    }()

    private lazy var addTrackerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addTrackerButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)

        setupUI()
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        categories = TrackerStore.shared.fetchAllCategories()
        print("📦 Загруженные категории: \(categories.count)")
        for category in categories {
            print("📂 \(category.title): \(category.trackers.count) трекеров")
        }
        reloadContent() // или applyFilteredSnapshot() — зависит от реализации
    }


    @objc private func dateChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        reloadContent()
    }

    private func reloadContent() {
        // Удаляем старые секции
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Корректируем systemWeekday: 1 (вс) → 7, 2 (пн) → 1, ..., 7 (сб) → 6
        let systemWeekday = Calendar.current.component(.weekday, from: currentDate)
        let adjustedWeekday = (systemWeekday + 5) % 7 + 1

        guard let selectedWeekday = Tracker.Weekday(rawValue: adjustedWeekday) else { return }

        // Фильтруем трекеры по выбранному дню недели
        let filtered = categories.map { category in
            TrackerCategory(
                title: category.title,
                trackers: category.trackers.filter { $0.schedule.contains(selectedWeekday) }
            )
        }.filter { !$0.trackers.isEmpty }

        // Обновляем видимость заглушки
        placeholderImageView.isHidden = !filtered.isEmpty
        placeholderLabel.isHidden = !filtered.isEmpty

        // Добавляем секции в контент
        for category in filtered {
            let sectionView = makeCategorySection(title: category.title, trackers: category.trackers)
            contentStack.addArrangedSubview(sectionView)
        }
    }


    private func makeCategorySection(title: String, trackers: [Tracker]) -> UIView {
        let sectionStack = UIStackView()
        sectionStack.axis = .vertical
        sectionStack.spacing = 12
        sectionStack.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .YPFont(17, weight: .bold)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 80)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        let dataSource = TrackerSectionDataSource(trackers: trackers)
        sectionDataSources.append(dataSource)
        collectionView.dataSource = dataSource
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.heightAnchor.constraint(equalToConstant: CGFloat(trackers.count) * 92).isActive = true
        

        sectionStack.addArrangedSubview(titleLabel)
        sectionStack.addArrangedSubview(collectionView)

        return sectionStack
    }

    @objc private func didTapAdd() {
        let vc = TrackerTypeViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    private func setupUI() {
        // Заголовок "Трекеры"
        titleLabel.text = "Трекеры"
        titleLabel.font = .YPFont(34, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // Контентный стек
        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        // Поле поиска
        searchBar.placeholder = "Поиск"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(searchBar)

        // Заглушка
        placeholderImageView.image = UIImage(resource: .starRing)
        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(placeholderImageView)

        placeholderLabel.text = "Что будем отслеживать?"
        placeholderLabel.font = .YPFont(12, weight: .medium)
        placeholderLabel.textColor = .ypBlack
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(placeholderLabel)
    }


    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Заголовок
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            // ScrollView
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Stack внутри scrollView
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),

            // Заглушка — по центру scrollView
            placeholderImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: -40),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),

            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 12),
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholderImageView.centerXAnchor),
        ])
    }

}
