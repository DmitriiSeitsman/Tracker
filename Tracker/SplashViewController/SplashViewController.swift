import UIKit

final class SplashViewController: UIViewController {
    
    private var imageView = UIImageView()
    
    private static var window: UIWindow? {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return scene.windows.first
        }
        return nil
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
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        
        guard let window = SplashViewController.window else {
            print("❌ Не удалось получить окно")
            return
        }
        
        if hasSeenOnboarding {
            let tabBarVC = TabBarController()
            window.rootViewController = tabBarVC
        } else {
            let onboardingVC = OnboardingViewController()
            onboardingVC.onFinish = {
                UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                
                let tabBarVC = TabBarController()
                window.rootViewController = tabBarVC
                UIView.transition(with: window,
                                  duration: 0.4,
                                  options: .transitionCrossDissolve,
                                  animations: nil,
                                  completion: nil)
            }
            
            window.rootViewController = onboardingVC
        }
        window.makeKeyAndVisible()
    }
}
