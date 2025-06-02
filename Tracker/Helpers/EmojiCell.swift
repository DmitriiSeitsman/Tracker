import UIKit

final class EmojiCell: UICollectionViewCell {
    static let reuseIdentifier = "EmojiCell"
    
    private let backgroundViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(backgroundViewContainer)
        backgroundViewContainer.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            backgroundViewContainer.widthAnchor.constraint(equalToConstant: 52),
            backgroundViewContainer.heightAnchor.constraint(equalToConstant: 52),
            backgroundViewContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            backgroundViewContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            emojiLabel.centerXAnchor.constraint(equalTo: backgroundViewContainer.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: backgroundViewContainer.centerYAnchor)
        ])
    }
    
    func configure(with emoji: String, selected: Bool) {
        emojiLabel.text = emoji
        backgroundViewContainer.backgroundColor = selected
        ? UIColor.ypGray.withAlphaComponent(0.3)
        : .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
