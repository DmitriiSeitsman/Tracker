import UIKit

final class ColorCell: UICollectionViewCell {
    static let reuseIdentifier = "ColorCell"
    
    private let whiteBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let colorCircleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(whiteBackgroundView)
        whiteBackgroundView.addSubview(colorCircleView)
        
        NSLayoutConstraint.activate([
            whiteBackgroundView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            whiteBackgroundView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            whiteBackgroundView.widthAnchor.constraint(equalToConstant: 52),
            whiteBackgroundView.heightAnchor.constraint(equalToConstant: 52),
            
            colorCircleView.centerXAnchor.constraint(equalTo: whiteBackgroundView.centerXAnchor),
            colorCircleView.centerYAnchor.constraint(equalTo: whiteBackgroundView.centerYAnchor),
            colorCircleView.widthAnchor.constraint(equalToConstant: 40),
            colorCircleView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        whiteBackgroundView.layer.borderWidth = 0
        whiteBackgroundView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func configure(with color: UIColor, selected: Bool) {
        colorCircleView.backgroundColor = color
        
        if selected {
            whiteBackgroundView.layer.borderWidth = 3
            whiteBackgroundView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        } else {
            whiteBackgroundView.layer.borderWidth = 0
            whiteBackgroundView.layer.borderColor = UIColor.clear.cgColor
        }
    }
}
