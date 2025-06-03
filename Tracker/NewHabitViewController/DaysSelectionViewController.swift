import UIKit

final class DaysSelectionViewController: UIViewController {
    
    // MARK: - Public Properties
    
    weak var delegate: DaysSelectionViewControllerDelegate?
    
    // MARK: - Private Properties
    
    private var selectedWeekdays: Set<Tracker.Weekday> = []
    private var switchMap: [Tracker.Weekday: UISwitch] = [:]
    
    // MARK: - UI Elements
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let daysStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let daysContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypBackgroundDay
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let days: [String] = [
        "Понедельник", "Вторник", "Среда", "Четверг",
        "Пятница", "Суббота", "Воскресенье"
    ]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Расписание"
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        view.backgroundColor = .ypWhite
        setupNavigationBarAppearance()
        setupLayout()
    }
    
    // MARK: - Public Methods
    
    func configure(with weekdays: Set<Tracker.Weekday>) {
        self.selectedWeekdays = weekdays
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypWhite
        appearance.titleTextAttributes = [
            .font: UIFont.YPFont(16, weight: .medium),
            .foregroundColor: UIColor.ypBlack
        ]
        appearance.shadowColor = .clear
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupLayout() {
        view.addSubview(daysContainerView)
        view.addSubview(doneButton)
        daysContainerView.addSubview(daysStack)
        
        NSLayoutConstraint.activate([
            daysContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            daysContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            daysContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            daysStack.topAnchor.constraint(equalTo: daysContainerView.topAnchor, constant: 16),
            daysStack.bottomAnchor.constraint(equalTo: daysContainerView.bottomAnchor, constant: -16),
            daysStack.leadingAnchor.constraint(equalTo: daysContainerView.leadingAnchor, constant: 16),
            daysStack.trailingAnchor.constraint(equalTo: daysContainerView.trailingAnchor, constant: -16),
            
            doneButton.topAnchor.constraint(equalTo: daysContainerView.bottomAnchor, constant: 47),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        for (dayName, weekday) in zip(days, Tracker.Weekday.allCases) {
            let dayRow = makeDaySwitchRow(title: dayName, day: weekday)
            daysStack.addArrangedSubview(dayRow)
            
            if weekday != Tracker.Weekday.allCases.last {
                let divider = makeDivider()
                daysStack.addArrangedSubview(divider)
            }
        }
    }
    
    private func makeDaySwitchRow(title: String, day: Tracker.Weekday) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .YPFont(17, weight: .regular)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let toggle = UISwitch()
        toggle.onTintColor = .ypBlue
        toggle.isOn = selectedWeekdays.contains(day)
        toggle.tag = day.rawValue
        toggle.addTarget(self, action: #selector(daySwitchChanged(_:)), for: .valueChanged)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        
        switchMap[day] = toggle
        
        let container = UIStackView(arrangedSubviews: [label, toggle])
        container.axis = .horizontal
        container.alignment = .center
        container.spacing = 0
        container.distribution = .fill
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        return container
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
    
    // MARK: - Actions
    
    @objc private func doneButtonTapped() {
        AnimationHelper.animateButtonPress(doneButton) { [weak self] in
            guard let self = self else { return }
            let selected = switchMap.compactMap { (key, toggle) in toggle.isOn ? key : nil }
            delegate?.didSelectWeekdays(Set(selected))
            dismiss(animated: true)
        }
    }
    
    @objc private func daySwitchChanged(_ sender: UISwitch) {
        guard let weekday = Tracker.Weekday(rawValue: sender.tag) else { return }
        if sender.isOn {
            selectedWeekdays.insert(weekday)
        } else {
            selectedWeekdays.remove(weekday)
        }
    }
}
