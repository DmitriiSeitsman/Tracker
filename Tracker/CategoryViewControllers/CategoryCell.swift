import UIKit

final class CategoryCell: UITableViewCell {
    static let reuseIdentifier = "CategoryCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .YPFont(17, weight: .regular)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .ypBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let background: UIView = {
        let view = UIView()
        view.backgroundColor = .ypLightGray
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        contentView.addSubview(background)
        background.addSubview(titleLabel)
        background.addSubview(checkmarkImageView)
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .ypLightGray
        backgroundColor = .clear


        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            background.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            background.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            background.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            background.heightAnchor.constraint(equalToConstant: 75),

            titleLabel.centerYAnchor.constraint(equalTo: background.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: 16),

            checkmarkImageView.centerYAnchor.constraint(equalTo: background.centerYAnchor),
            checkmarkImageView.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -16),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 20),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with title: String, selected: Bool) {
        titleLabel.text = title
        checkmarkImageView.isHidden = !selected
    }
}
