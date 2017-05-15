import UIKit
import Swinject
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    
    var shortcut: Shortcut?

    lazy var appContainer: Container = createContainer()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        let rootVC = appContainer.resolve(UIViewController.self, name: "root")!
        window?.rootViewController = rootVC
        window?.tintColor = Colors.accent.color
        window?.makeKeyAndVisible()
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert,.sound,.badge],
            completionHandler: { (granted, error) in
            }
        )
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        print("Shortcut pressed: \(shortcutItem)")
        print(shortcutItem.localizedTitle, shortcutItem.localizedSubtitle ?? "")
        guard let type = shortcutItem.type.components(separatedBy: ".").last else {
            print("Wrong shortcut type")
            return
        }
        print(type)
        shortcut = Shortcut(rawValue: type)
        completionHandler(true)
    }
}

enum Shortcut: String {
    case StartServer
    case ScanQR
}

