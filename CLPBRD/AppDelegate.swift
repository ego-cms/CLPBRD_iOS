import UIKit
import Swinject


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    lazy var appContainer: Container = createContainer()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        let rootVC = appContainer.resolve(MainViewController.self)!
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
        return true
    }
}

