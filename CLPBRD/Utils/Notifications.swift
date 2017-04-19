import Foundation
import UserNotifications


func showLocalNotification(text: String) {
    let content = UNMutableNotificationContent()
    content.title = "CLPBRD"
    content.subtitle = L10n.notificationTitle.string
    content.body = text
    content.categoryIdentifier = "message"
    
    let trigger = UNTimeIntervalNotificationTrigger(
        timeInterval: 0.5,
        repeats: false
    )
    
    let request = UNNotificationRequest(
        identifier: "copied",
        content: content,
        trigger: trigger
    )
    
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
}
