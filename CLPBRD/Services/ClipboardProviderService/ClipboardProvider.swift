import UIKit


class ClipboardProvider: NSObject, ClipboardProviderService {
    private let pasteboard = UIPasteboard.general
    
    var content: String? {
        get {
            return pasteboard.string
        }
        
        set {
            pasteboard.string = newValue
        }
    }
    
    private var shouldNotify = true
    
    var changeCount: Int {
        return pasteboard.changeCount
    }
    
    var onContentChanged: VoidClosure = { }
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(contentChanged), name: Notification.Name.UIPasteboardChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(contentChanged), name: Notification.Name.UIPasteboardRemoved, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(contentChanged), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func contentChanged() {
        guard shouldNotify else {
            shouldNotify = true
            return
        }
        onContentChanged()
    }
    
    func updateContentWithoutNotification(newContent: String) {
        shouldNotify = false
        content = newContent
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
