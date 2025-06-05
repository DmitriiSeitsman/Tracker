import UIKit

final class SplashViewController: UIViewController {
    
    private var imageView = UIImageView()
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Splash загружен")
        setupUI()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.switchToMainApp()
        }
    }
    
    private func setupUI() {
        self.view.backgroundColor = .ypBlue
        let splashImage = UIImage(resource: .trackerLogo)
        imageView = UIImageView(image: splashImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 91),
            imageView.heightAnchor.constraint(equalToConstant: 94)
        ])
    }
    
    private func switchToMainApp() {
            let tabBarController = TabBarController()
            
            guard let window = SplashViewController.window else {
                print("❌ Не удалось получить окно")
                return
            }

            window.rootViewController = tabBarController
            UIView.transition(with: window,
                              duration: 0.4,
                              options: .transitionCrossDissolve,
                              animations: nil,
                              completion: nil)
        }
}
