import UIKit

final class DaysSelectionViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = .YPFont(16, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        view.backgroundColor = .ypLightGray
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let days: [String] = [
        "Понедельник", "Вторник", "Среда", "Четверг",
        "Пятница", "Суббота", "Воскресенье"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        view.backgroundColor = .ypWhite
        setupLayout()
    }
    
    @objc private func doneButtonTapped() {
        dismiss(animated: true)
    }
    
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(daysContainerView)
        view.addSubview(doneButton)
        
        daysContainerView.addSubview(daysStack)
        
        NSLayoutConstraint.activate([
            // Заголовок
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Контейнер для дней недели
            daysContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            daysContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            daysContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Стек в контейнере
            daysStack.topAnchor.constraint(equalTo: daysContainerView.topAnchor, constant: 16),
            daysStack.bottomAnchor.constraint(equalTo: daysContainerView.bottomAnchor, constant: -16),
            daysStack.leadingAnchor.constraint(equalTo: daysContainerView.leadingAnchor, constant: 16),
            daysStack.trailingAnchor.constraint(equalTo: daysContainerView.trailingAnchor, constant: -16),
            
            // Кнопка "Готово"
            doneButton.topAnchor.constraint(equalTo: daysContainerView.bottomAnchor, constant: 47),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        
        for (index, day) in days.enumerated() {
            let dayRow = makeDaySwitchRow(title: day)
            daysStack.addArrangedSubview(dayRow)
            
            if index < days.count - 1 {
                let divider = makeDivider()
                divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
                daysStack.addArrangedSubview(divider)
            }
        }
        
    }
    
    private func makeDaySwitchRow(title: String) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .YPFont(17, weight: .regular)
        label.textColor = .label

        let toggle = UISwitch()
        toggle.onTintColor = .ypBlue

        let container = UIStackView(arrangedSubviews: [label, toggle])
        container.axis = .horizontal
        container.alignment = .center
        container.spacing = 0
        container.translatesAutoresizingMaskIntoConstraints = false
        container.distribution = .fill

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
    
}
