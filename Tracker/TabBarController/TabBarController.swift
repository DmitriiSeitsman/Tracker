import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackersVC = TrackersViewController()
        let navTrackersVC = UINavigationController(rootViewController: trackersVC)
        navTrackersVC.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .trackIcon),
            tag: 0
        )

        let statisticVC = StatisticViewController()
        let navStatisticVC = UINavigationController(rootViewController: statisticVC)
        navStatisticVC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .statIcon),
            tag: 1
        )

        viewControllers = [navTrackersVC, navStatisticVC]
        
        tabBar.backgroundColor = .ypWhite
        tabBar.isTranslucent = false
        
        addTabBarTopBorder()
    }
    
    private func addTabBarTopBorder() {
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = .ypGray

        tabBar.addSubview(border)

        NSLayoutConstraint.activate([
            border.topAnchor.constraint(equalTo: tabBar.topAnchor),
            border.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            border.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale) // 1pt
        ])
    }
}

