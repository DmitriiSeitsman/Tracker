import UIKit

enum YPFontName {
    static let regular = "SF-Pro-Text-Regular"
    static let medium = "SF-Pro-Text-Medium"
    static let bold = "SF-Pro-Text-Bold"
}

extension UIFont {
    static func YPFont(_ size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let name: String

        switch weight {
        case .bold:
            name = YPFontName.bold
        case .medium:
            name = YPFontName.medium
        default:
            name = YPFontName.regular
        }

        return UIFont(name: name, size: size) ?? .systemFont(ofSize: size, weight: weight)
    }
}
