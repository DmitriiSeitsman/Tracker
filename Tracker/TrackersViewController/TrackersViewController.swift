import UIKit

final class TrackersViewController: UIViewController {
    
    var categories: [TrackerCategory] = []
    var currentDate: Date = Date()
    
    private var sectionDataSources: [UICollectionViewDataSource] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentFilter: FilterType = .all
    
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
    
    private let filtersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Фильтры", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.backgroundColor = .ypBlue
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addTrackerButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        view.addSubview(filtersButton)
        filtersButton.addTarget(self, action: #selector(didTapFilters), for: .touchUpInside)
        
        setupUI()
        setupConstraints()
        categories = TrackerStore.shared.fetchAllCategories()
        view.bringSubviewToFront(filtersButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.global(qos: .userInitiated).async {
            let loadedCategories = TrackerStore.shared.fetchAllCategories()
            
            DispatchQueue.main.async {
                self.categories = loadedCategories
                self.reloadContent()
            }
        }
    }
    
    @objc private func didTapFilters() {
        let filterVC = FilterViewController()
        filterVC.delegate = self
        filterVC.selectedFilter = currentFilter
        filterVC.modalPresentationStyle = .pageSheet
        present(filterVC, animated: true)
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        reloadContent()
    }
    
    private func reloadContent() {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let calendar = Calendar.current
        let selectedDay = calendar.startOfDay(for: currentDate)
        let systemWeekday = calendar.component(.weekday, from: currentDate)
        let adjustedWeekday = (systemWeekday + 5) % 7 + 1
        
        guard let selectedWeekday = Tracker.Weekday(rawValue: adjustedWeekday) else { return }
        completedTrackers = TrackerRecordStore.shared.fetchAllRecords()
        
        let filtered = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                let createdDay = calendar.startOfDay(for: tracker.createdAt)
                
                let matchesDate: Bool = tracker.schedule.isEmpty
                ? createdDay == selectedDay
                : tracker.schedule.contains(selectedWeekday)
                
                let isCompleted = completedTrackers.contains {
                    $0.id == tracker.id && calendar.isDate($0.date, inSameDayAs: selectedDay)
                }
                
                switch currentFilter {
                case .all:
                    return matchesDate
                case .today:
                    return matchesDate && calendar.isDateInToday(currentDate)
                case .completed:
                    return matchesDate && isCompleted
                case .notCompleted:
                    return matchesDate && !isCompleted
                }
            }
            
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
            .filter { !$0.trackers.isEmpty }
        
        placeholderImageView.isHidden = !filtered.isEmpty
        placeholderLabel.isHidden = !filtered.isEmpty
        
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
        
        // Layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 7
        layout.sectionInset = .zero
        
        let availableWidth = UIScreen.main.bounds.width - 32
        let itemSpacing: CGFloat = layout.minimumInteritemSpacing
        let itemWidth = (availableWidth - itemSpacing) / 2
        let itemHeight: CGFloat = 148
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        
        // CollectionView
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        
        // DataSource
        let dataSource = TrackerSectionDataSource(
            trackers: trackers,
            completedTrackers: completedTrackers,
            currentDate: currentDate
        ) { [weak self] tracker, currentlyCompleted in
            guard let self = self else { return }
            
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let selectedDay = calendar.startOfDay(for: self.currentDate)
            
            guard selectedDay <= today else {
                print("Нельзя отмечать трекеры на будущую дату: \(selectedDay)")
                return
            }
            
            if currentlyCompleted {
                TrackerRecordStore.shared.removeRecord(for: tracker.id, on: selectedDay)
            } else {
                TrackerRecordStore.shared.addRecord(for: tracker.id, on: selectedDay)
            }
            
            self.reloadContent()
        }
        
        sectionDataSources.append(dataSource)
        collectionView.dataSource = dataSource
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        
        // Расчёт высоты
        let rows = ceil(Double(trackers.count) / 2.0)
        let rowHeight = itemHeight + layout.minimumLineSpacing
        let totalHeight = CGFloat(rows) * rowHeight - layout.minimumLineSpacing
        collectionView.heightAnchor.constraint(equalToConstant: totalHeight).isActive = true
        
        sectionStack.addArrangedSubview(titleLabel)
        sectionStack.addArrangedSubview(collectionView)
        
        return sectionStack
    }
    
    
    
    @objc private func didTapAdd() {
        let vc = TrackerTypeViewController()
        vc.currentDate = self.currentDate
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    private func setupUI() {
        // Заголовок "Трекеры"
        titleLabel.text = "Трекеры"
        titleLabel.font = .YPFont(34, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Поле поиска
        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.heightAnchor.constraint(equalToConstant: 36).isActive = true
        view.addSubview(searchBar)
        
        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Контентный стек
        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
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
            // Кнопка фильтры
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
            
            // Заголовок
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            // Поиск
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
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

extension TrackersViewController: FilterSelectionDelegate {
    func didSelectFilter(_ filter: FilterType) {
        print("Выбран фильтр:", filter.title)
        currentFilter = filter
        reloadContent()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.dismiss(animated: true)
        }
    }
}


