import UIKit

final class StatisticViewController: UIViewController {
    
    private let titleLabel = UILabel()
    private let stackView = UIStackView()
    
    private let placeholderImage = UIImageView()
    private let placeholderLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupTitleLabel()
        setupUI()
        layoutUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatistics()
    }
    
    private func setupTitleLabel() {
        titleLabel.text = NSLocalizedString("statistics_title", comment: "Statistics screen title")
        titleLabel.font = .YPFont(34, weight: .bold)
        titleLabel.textColor = .ypBlack
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
    }
    
    private func setupUI() {
        // StackView
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // Placeholder
        placeholderImage.image = UIImage(resource: .statStub)
        placeholderImage.translatesAutoresizingMaskIntoConstraints = false
        
        placeholderLabel.text = NSLocalizedString("statistics_placeholder", comment: "Empty state message")
        placeholderLabel.font = .YPFont(12, weight: .medium)
        placeholderLabel.textColor = .ypBlack
        placeholderLabel.textAlignment = .center
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(placeholderImage)
        view.addSubview(placeholderLabel)
    }
    
    private func layoutUI() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 53),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            placeholderImage.widthAnchor.constraint(equalToConstant: 80),
            placeholderImage.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func updateStatistics() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() } // очищаем

        let groupedRecords = TrackerRecordStore.shared.groupRecordsByDate()
        let allTrackers = TrackerStore.shared.fetchAllTrackersAsModels()
        
        let (bestStreak, perfectDays, totalCompleted, averagePerDay) = StatisticsCalculator.calculate(
            groupedRecords: groupedRecords,
            allTrackers: allTrackers
        )

        let stats = [
            (value: bestStreak, title: NSLocalizedString("statistics_best_streak", comment: "")),
            (value: perfectDays, title: NSLocalizedString("statistics_perfect_days", comment: "")),
            (value: totalCompleted, title: NSLocalizedString("statistics_total_completed", comment: "")),
            (value: averagePerDay, title: NSLocalizedString("statistics_average", comment: ""))
        ]
        
        let hasData = stats.contains { $0.value > 0 }

        placeholderImage.isHidden = hasData
        placeholderLabel.isHidden = hasData
        stackView.isHidden = !hasData
        
        if hasData {
            stats.forEach {
                let card = StatCardView(value: "\($0.value)", title: $0.title)
                card.heightAnchor.constraint(equalToConstant: 90).isActive = true
                stackView.addArrangedSubview(card)
            }
        }
    }
}
