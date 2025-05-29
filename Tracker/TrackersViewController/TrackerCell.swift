import UIKit

final class TrackerCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackerCell"

    // MARK: - UI
    
    private let emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.widthAnchor.constraint(equalToConstant: 22).isActive = true
        label.heightAnchor.constraint(equalToConstant: 16).isActive = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .YPFont(12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .ypBlack
        label.text = "0 дней"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .ypBlack
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 34).isActive = true
        button.heightAnchor.constraint(equalToConstant: 34).isActive = true
        button.layer.cornerRadius = 17
        button.clipsToBounds = true
        return button
    }()

    private let topView = UIView()
    private let bottomView = UIView()

    private let bottomStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.backgroundColor = .ypWhite
        stack.heightAnchor.constraint(equalToConstant: 58).isActive = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let verticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.heightAnchor.constraint(greaterThanOrEqualToConstant: 90).isActive = true
        stack.layer.cornerRadius = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Data

    private var tracker: Tracker?
    private var isCompletedToday: Bool = false
    var toggleCompletion: ((_ tracker: Tracker, _ currentlyCompleted: Bool) -> Void)?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with tracker: Tracker, completedDays: Int, isCompletedToday: Bool) {
        self.tracker = tracker
        self.isCompletedToday = isCompletedToday

        verticalStack.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        contentView.backgroundColor = .ypWhite
        

        let iconName = isCompletedToday ? "checkmark" : "plus"
        actionButton.setImage(UIImage(systemName: iconName), for: .normal)
        actionButton.backgroundColor = tracker.color

        countLabel.text = "\(completedDays) \(daysWord(for: completedDays))"

        actionButton.removeTarget(nil, action: nil, for: .allEvents)
        actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
    }

    private func daysWord(for count: Int) -> String {
        switch count % 10 {
        case 1 where count % 100 != 11: return "день"
        case 2...4 where !(12...14).contains(count % 100): return "дня"
        default: return "дней"
        }
    }

    // MARK: - Actions

    @objc private func didTapActionButton() {
        guard let tracker = tracker else { return }
        toggleCompletion?(tracker, isCompletedToday)
    }

    // MARK: - UI Setup

    private func setupUI() {
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        contentView.backgroundColor = .ypLightGray

        contentView.addSubview(verticalStack)
        contentView.addSubview(bottomStack)

        // Верх
        verticalStack.addArrangedSubview(topView)
        topView.addSubview(emojiBackgroundView)
        emojiBackgroundView.addSubview(emojiLabel)
        topView.addSubview(titleLabel)

        // Низ
        let spacer = UIView()
        bottomStack.addArrangedSubview(countLabel)
        bottomStack.addArrangedSubview(spacer)
        bottomStack.addArrangedSubview(actionButton)

        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        countLabel.setContentHuggingPriority(.required, for: .horizontal)
        actionButton.setContentHuggingPriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            // Верхняя часть
            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            verticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            verticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            // Подложка под эмоджи
            emojiBackgroundView.topAnchor.constraint(equalTo: topView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),

            // Эмоджи по центру подложки
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            
            // Название трекера
            titleLabel.topAnchor.constraint(equalTo: emojiBackgroundView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: 12),

            // Нижняя часть
            bottomStack.topAnchor.constraint(equalTo: verticalStack.bottomAnchor, constant: 0),
            bottomStack.leadingAnchor.constraint(equalTo: verticalStack.leadingAnchor, constant: 0),
            bottomStack.trailingAnchor.constraint(equalTo: verticalStack.trailingAnchor, constant: 0),
            bottomStack.heightAnchor.constraint(equalToConstant: 58),
            
            //счетчик трекера
            countLabel.topAnchor.constraint(equalTo: bottomStack.topAnchor, constant: 16),
            countLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 12),
            
            //кнопка "+"
            actionButton.topAnchor.constraint(equalTo: bottomStack.topAnchor, constant: 8),
            actionButton.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -12),
            actionButton.bottomAnchor.constraint(equalTo: bottomStack.bottomAnchor, constant: -16)
        ])

    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.backgroundColor = .ypLightGray
        tracker = nil
        isCompletedToday = false
    }
}
