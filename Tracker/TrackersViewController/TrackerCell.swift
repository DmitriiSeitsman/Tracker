import UIKit

protocol TrackerCellDelegate: AnyObject {
    func didTogglePin(for tracker: Tracker?)
    func didRequestEdit(for tracker: Tracker?)
    func didRequestDelete(for tracker: Tracker?)
}

final class TrackerCell: UICollectionViewCell {

    static let reuseIdentifier = "TrackerCell"
    
    // MARK: - Delegate
    weak var delegate: TrackerCellDelegate?

    // MARK: - Data
    private var tracker: Tracker?
    private var isCompletedToday: Bool = false
    var toggleCompletion: ((_ tracker: Tracker, _ currentlyCompleted: Bool) -> Void)?
    var isPinned: Bool = false

    // MARK: - UI
    
    private let emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
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
        label.font = .YPFont(12, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .ypBlack
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
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
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let verticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.layer.cornerRadius = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        let interaction = UIContextMenuInteraction(delegate: self)
        self.addInteraction(interaction)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    
    func configure(with tracker: Tracker, completedDays: Int, isCompletedToday: Bool, isPinned: Bool = false) {
        self.tracker = tracker
        self.isCompletedToday = isCompletedToday
        self.isPinned = isPinned

        verticalStack.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        countLabel.text = "\(completedDays) \(daysWord(for: completedDays))"
        
        let iconName = isCompletedToday ? "checkmark" : "plus"
        actionButton.setImage(UIImage(systemName: iconName), for: .normal)
        actionButton.backgroundColor = tracker.color
    }

    // MARK: - Actions
    
    @objc private func didTapActionButton() {
        print("Action button tapped")
        guard let tracker = tracker else { return }
        toggleCompletion?(tracker, isCompletedToday)
    }

    // MARK: - UI Setup
    
    private func setupUI() {
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        contentView.backgroundColor = .clear
        
        contentView.addSubview(verticalStack)
        contentView.addSubview(bottomStack)
        
        verticalStack.addArrangedSubview(topView)
        bottomStack.addArrangedSubview(bottomView)
        topView.addSubview(emojiBackgroundView)
        emojiBackgroundView.addSubview(emojiLabel)
        topView.addSubview(titleLabel)
        bottomView.addSubview(countLabel)
        bottomView.addSubview(actionButton)
        bottomView.backgroundColor = .clear
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.heightAnchor.constraint(equalToConstant: 58).isActive = true
        
        actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)

        NSLayoutConstraint.activate([
           
            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            verticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            verticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            verticalStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 90),

            emojiBackgroundView.topAnchor.constraint(equalTo: topView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: emojiBackgroundView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -12),

            bottomStack.topAnchor.constraint(equalTo: verticalStack.bottomAnchor),
            bottomStack.leadingAnchor.constraint(equalTo: verticalStack.leadingAnchor),
            bottomStack.trailingAnchor.constraint(equalTo: verticalStack.trailingAnchor),
            
            countLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 12),
            actionButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -12),
            actionButton.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 8),
            countLabel.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 34),
            actionButton.heightAnchor.constraint(equalToConstant: 34),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        tracker = nil
        isCompletedToday = false
        toggleCompletion = nil
    }
}

// MARK: - Context Menu

extension TrackerCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let pin = UIAction(title: self.isPinned ? "Открепить" : "Закрепить", image: UIImage(systemName: "pin")) { _ in
                self.delegate?.didTogglePin(for: self.tracker)
            }
            let edit = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { _ in
                self.delegate?.didRequestEdit(for: self.tracker)
            }
            let delete = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.delegate?.didRequestDelete(for: self.tracker)
            }
            return UIMenu(title: "", children: [pin, edit, delete])
        }
    }
}
