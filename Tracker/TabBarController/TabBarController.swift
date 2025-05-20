import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let trackersVC = TrackersViewController()
        trackersVC.tabBarItem = UITabBarItem(
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

        viewControllers = [trackersVC, navStatisticVC]
    }
}
