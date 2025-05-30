import UIKit

func hexString(from color: UIColor) -> String {
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
    color.getRed(&red, green: &green, blue: &blue, alpha: nil)

    let r = Int(red * 255)
    let g = Int(green * 255)
    let b = Int(blue * 255)

    return String(format: "#%02X%02X%02X", r, g, b)
}
