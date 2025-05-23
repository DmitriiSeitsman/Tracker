import UIKit

final class TrackerTypeViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.font = .YPFont(16, weight: .medium)
        label.textAlignment = .center
        label.textColor = .ypBlack
        return label
    }()

    private let habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .ypBlack
        button.titleLabel?.font = .YPFont(16, weight: .medium)
        button.layer.cornerRadius = 16
        return button
    }()

    private let irregularEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Нерегулярное событие", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .ypBlack
        button.titleLabel?.font = .YPFont(16, weight: .medium)
        button.layer.cornerRadius = 16
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupLayout()
        habitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)

    }
    
    @objc private func habitButtonTapped() {
        print("habitButtonTapped")
        let navVC = UINavigationController(rootViewController: NewHabitViewController())
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }

    private func setupLayout() {
            [titleLabel, habitButton, irregularEventButton].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview($0)
            }

            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
                titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                habitButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 395),
                habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                habitButton.heightAnchor.constraint(equalToConstant: 60),

                irregularEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
                irregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                irregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                irregularEventButton.heightAnchor.constraint(equalToConstant: 60),
            ])
        }
    }
