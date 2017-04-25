import UIKit
import Swinject


func loadAndTranslatePath(fileName: String) -> UIBezierPath {
    let path = loadSVG(from: fileName)
    let origin = path.bounds.origin
    let transform = CGAffineTransform(translationX: -origin.x, y: -origin.y)
    path.apply(transform)
    return path
}


class ControlPanelViewController: UIViewController {
    var animationDuration = 0.25
    
    private(set) var state: State = .off {
        didSet {
            updateContainerVisibility()
        }
    }
    
    private var isAnimationInflight = false
    
    @IBOutlet weak var toggleButton: RoundButton!
    @IBOutlet weak var scanQRButton: RoundButton!
    
    @IBOutlet weak var buttonBackgroundOffDummy: UIView!
    @IBOutlet weak var buttonBackgroundOnDummy: UIView!
    @IBOutlet weak var scanQROffDummy: UIView!
    @IBOutlet weak var scanQROnDummy: UIView!
    @IBOutlet weak var toggleOffDummy: UIView!
    @IBOutlet weak var toggleOnDummy: UIView!
    @IBOutlet weak var arrowDummy: UIView!
    @IBOutlet weak var magicButtonLabelDummy: UIView!
    
    @IBOutlet weak var serverInfoContainer: UIView!
    @IBOutlet weak var serverAddressLabel: UILabel!
    @IBOutlet weak var offInfoContainer: UIView!
    @IBOutlet weak var showQRButton: UIButton!
    @IBOutlet weak var addressDescriptionLabel: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var buttonBackgroundView: ButtonBackgroundView!
    @IBOutlet weak var magicButtonLabel: UILabel!
    
    @IBOutlet weak var promptToScanLabel: UILabel!
    var receivedText: String?
    var alreadyRecognized = false
    
    var localServerURL: URL? {
        didSet {
            serverAddressLabel.text = clipboardSyncServerService.serverURL?.absoluteString ?? ""
        }
    }
    
    let httpPort: UInt = 8080
    
    var clipboardSyncServerService: ClipboardSyncServerService
    var clipboardSyncClientService: ClipboardSyncClientService
    
    unowned var container: Container
    
    init(
        container: Container,
        clipboardSyncServerService: ClipboardSyncServerService,
        clipboardSyncClientService: ClipboardSyncClientService
    ) {
        self.container = container
        self.clipboardSyncServerService = clipboardSyncServerService
        self.clipboardSyncClientService = clipboardSyncClientService
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appEnteredForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func clipboardSyncServiceStateChanged(newState: ServerState) {
        print("SYNC SERVER: state changed to \(newState)")
        if newState == .off {
            updateState(to: .off)
        } else {
            updateState(to: .serverOn)
        }
    }
    
    func updatesReceived() {
        print("SYNC SERVER: received updates")
        updateState(to: .serverGotUpdates)
    }
    
    func appEnteredForeground() {
        delay(0.5) {
            self.handleShortcuts()
        }
    }
    
    func startServer() {
        turnOffEverything()
        clipboardSyncServerService.onStateChanged = clipboardSyncServiceStateChanged
        clipboardSyncServerService.onUpdatesReceived = updatesReceived
        clipboardSyncServerService.start(port: httpPort)
        localServerURL = clipboardSyncServerService.serverURL
    }
    
    func startClient(host: String) {
        turnOffEverything()
        clipboardSyncClientService.onConnected = clientConnected
        clipboardSyncClientService.onUpdatesReceived = clientReceivedUpdates
        clipboardSyncClientService.onDisconnected = clientDisconnected
        clipboardSyncClientService.connect(host: host, port: httpPort)
        serverAddressLabel.text = URL.createBrowserURL(with: host, port: httpPort)?.absoluteString ?? ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func scanQRPressed() {
        let qrCodeScanViewController = container.resolve(QRCodeScanViewController.self)!
        qrCodeScanViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: qrCodeScanViewController)
        navigationController.modalPresentationStyle = .overFullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func showQRPressed(_ sender: Any) {
        let qrCodeDisplayViewController = container.resolve(QRCodeDisplayViewController.self)!
        qrCodeDisplayViewController.delegate = self
        qrCodeDisplayViewController.qrDisplayService.text = "clpbrd://" + (localServerURL?.host ?? "")
        let navigationController = UINavigationController(rootViewController: qrCodeDisplayViewController)
        navigationController.view.backgroundColor = .clear
        navigationController.modalPresentationStyle = .overFullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.sendSubview(toBack: scanQRButton)
        view.sendSubview(toBack: buttonBackgroundOffDummy)
        view.sendSubview(toBack: buttonBackgroundView)
        buttonBackgroundOffDummy.isHidden = true
        setup(button: scanQRButton, highlightColor: Colors.scanQRButtonHighlighted.color, normalColor: Colors.scanQRButtonNormal.color)
        setup(button: toggleButton, highlightColor: Colors.toggleButtonOffHighlighted.color, normalColor: Colors.toggleButtonOffNormal.color)
        toggleButton.setTitle(toggleButtonTitle(for: state), for: .normal)
        promptToScanLabel.text = L10n.promptToScan.string
        magicButtonLabel.text = L10n.magicButton.string
        updateContainerVisibility(animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        if appDelegate.shortcut != .StartServer {
            delay(0.3) {
                self.animateArrow(visible: true)
            }
        }
        handleShortcuts()
    }
    
    func handleShortcuts() {
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        guard let shortcut = appDelegate.shortcut else {
            return
        }
        appDelegate.shortcut = nil
        
        animationDuration = 0
        defer {
            animationDuration = 0.25
        }
        switch shortcut {
        case .StartServer:
            if state.isServer { return }
            animateArrow(visible: false, animated: false)
            toggleButtonPressed()
        case .ScanQR:
            turnOffEverything(animated: false)
            scanQRPressed()
        }
    }
    
    func setup(button: RoundButton, highlightColor: UIColor, normalColor: UIColor) {
        button.highlightColor = highlightColor
        button.normalColor = normalColor
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isAnimationInflight {
            updateUI()
        }
    }
    
    func updateUI() {
        self.updateButtonFrames()
        self.buttonBackgroundView.frame = self.buttonBackgroundViewFrame(for: self.state)
        self.updateArrow()
        self.buttonBackgroundView.heightInExpandedState = self.buttonBackgroundView.frame.height
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        delay(0.2) {
            self.updateUI()
        }
    }

    // MARK: Client callbacks
    
    func clientConnected() {
        print("SYNC CLIENT: connected to server")
        updateState(to: .clientOn)
    }
    
    func clientReceivedUpdates() {
        print("SYNC CLIENT: received updates")
        updateState(to: .clientGotUpdates)
    }
    
    func clientDisconnected(error: Error?) {
        print("SYNC CLIENT: disconnected with error \(String(describing: error))")
        updateState(to: .off)
    }
    
    func updateContainerVisibility(animated: Bool = true) {
        let visible = state == .off ? offInfoContainer : serverInfoContainer
        let invisible = state != .off ? offInfoContainer : serverInfoContainer
        let duration = animated ? animationDuration : 0.0
        UIView.animate(withDuration: duration) {
            visible?.alpha = 1.0
            invisible?.alpha = 0.0
        }
    }
    
    func updateButtonFrames() {
        self.toggleButton.frame = self.toggleButtonFrame(for: self.state)
        self.scanQRButton.frame = self.qrButtonFrame(for: self.state)
    }
    
    @IBAction func toggleButtonPressed() {
        switch state {
        case .serverOn:
            turnOffEverything(animated: true)
        case .serverGotUpdates:
            clipboardSyncServerService.takeUpdates()
            makeNotification(clipboardContent: UIPasteboard.general.string ?? "")
            updateState(to: .serverOn)
            
        case .clientOn:
            turnOffEverything(animated: true)
        case .clientGotUpdates:
            clipboardSyncClientService.takeUpdates()
            makeNotification(clipboardContent: UIPasteboard.general.string ?? "")
            updateState(to: .clientOn)
        case .off:
            startServer()
        }
    }
    
    func turnOffEverything(animated: Bool = true) {
        presentedViewController?.dismiss(animated: false, completion: nil)
        clipboardSyncServerService.stop()
        clipboardSyncClientService.disconnect()
        updateState(to: .off, animated: animated)
    }
    
    func dummyFrame(dummy: UIView) -> CGRect {
        return dummy.superview!.convert(dummy.frame, to: self.view)
    }

    func toggleButtonFrame(for state: State) -> CGRect {
        switch state {
        case .off: return dummyFrame(dummy: toggleOffDummy)
        default: return dummyFrame(dummy: toggleOnDummy)
        }
    }
    
    func buttonBackgroundViewFrame(for state: State) -> CGRect {
        if state.isOff {
            return dummyFrame(dummy: buttonBackgroundOffDummy) }
        return dummyFrame(dummy: buttonBackgroundOnDummy)
    }
    
    func qrButtonFrame(for state: State) -> CGRect {
        switch state {
        case .off: return dummyFrame(dummy: scanQROffDummy)
        default: return dummyFrame(dummy: scanQROnDummy)
        }
    }
    
    func qrButtonAlpha(for state: State) -> CGFloat {
        return state.isOff ? 1.0 : 0.0
    }
    
    func toggleButtonNormalColor(for state: State) -> UIColor {
        if state.isOn { return Colors.toggleButtonOnNormal.color }
        if state.gotUpdates { return Colors.toggleButtonGotUpdatesNormal.color }
        return Colors.toggleButtonOffNormal.color
    }
    
    func toggleButtonHighlightedColor(for state: State) -> UIColor {
        if state.isOn { return Colors.toggleButtonOnHighlighted.color }
        if state.gotUpdates { return Colors.toggleButtonGotUpdatesHighlighted.color }
        return Colors.toggleButtonOffHighlighted.color
    }
    
    func toggleButtonTitle(for state: State) -> String {
        if state.isOn { return L10n.buttonOnTitle.string }
        if state.gotUpdates { return "↓" }
        return L10n.buttonOffTitle.string
    }

    func addressDescription(for state: State) -> String {
        if state.isClient { return L10n.clientAddressExplanation.string }
            //"Вы соединены с устройством по этому адресу" }
        if state.isServer { return L10n.serverAddressExplanation.string }
            //"Используйте этот адрес в браузере, чтобы соединиться" }
        return ""
    }
    
    var toggleButtonPositionsDistance: CGFloat {
        return dummyFrame(dummy: toggleOffDummy).center.x - dummyFrame(dummy: toggleOnDummy).center.x
    }

    func performTransition(from oldState: State, to newState: State, animated: Bool = true) {
        print("Transitioning from \(oldState) to \(newState) animated \(animated)")
        self.addressDescriptionLabel.text = self.addressDescription(for: newState)
        self.showQRButton.isHidden = newState.isClient
        let multiplier: CGFloat = (newState.isOff ? 1.0 : 0.0) - (oldState.isOff ? 1.0 : 0.0)
        let deltaX = multiplier * toggleButtonPositionsDistance
        let duration = animated ? animationDuration : 0.0
        
        let shapePathAnimationTrigger = {
            print("shape path animation")
            self.buttonBackgroundView.changeState(to: newState.buttonBackgroundViewState, animated: animated)
        }
        
        let shapePositionAnimationTrigger = {
            print("shape position animation")
            UIView.animate(withDuration: duration) {
                self.buttonBackgroundView.center.x += deltaX
            }
        }
        let scanQRButtonAnimationTrigger = {
            print("scan qr animation")
            UIView.animate(withDuration: duration) {
                self.scanQRButton.frame = self.qrButtonFrame(for: newState)
                self.scanQRButton.alpha = self.qrButtonAlpha(for: newState)
            }
        }
        
        let toggleButtonPositionAnimationTrigger = {
            print("toggle button animation")
            UIView.animate(withDuration: duration) {
                self.toggleButton.center.x += deltaX
            }
        }
        self.toggleButton.setTitle(self.toggleButtonTitle(for: newState), for: .normal)
        self.toggleButton.normalColor = self.toggleButtonNormalColor(for: newState)
        self.toggleButton.highlightColor = self.toggleButtonHighlightedColor(for: newState)
        
        isAnimationInflight = true
        delay(2 * duration) { 
            self.isAnimationInflight = false
        }
        var triggers = [
            shapePathAnimationTrigger,
            scanQRButtonAnimationTrigger,
            shapePositionAnimationTrigger,
            toggleButtonPositionAnimationTrigger
        ]
        if newState == .off { triggers.reverse() }
        animate(
            triggers: triggers,
            delays: [
                0.0,
                0.0,
                duration,
                0.0
            ]
        )
    }
    
    func updateState(to newState: State, animated: Bool = true) {
        if state == newState, !state.gotUpdates {
            return
        }
        performTransition(from: self.state, to: newState, animated: animated)
        animateArrow(visible: newState == .off, animated: animated)
        self.state = newState
    }
    
    func makeNotification(clipboardContent: String) {
        showLocalNotification(text: clipboardContent)
    }
    
    func updateArrow() {
        arrowImage.frame = dummyFrame(dummy: arrowDummy)
        magicButtonLabel.frame = dummyFrame(dummy: magicButtonLabelDummy)
    }
    
    func animateArrow(visible: Bool, animated: Bool = true) {
        let currentVisible = arrowImage.alpha != 0.0
        guard currentVisible != visible else { return }
        magicButtonLabel.frame = dummyFrame(dummy: magicButtonLabelDummy)
        let duration = animated ? animationDuration : 0.0
        if visible {
            let arrowTargetFrame = dummyFrame(dummy: arrowDummy)
            arrowImage.frame = arrowTargetFrame
            arrowImage.transform = CGAffineTransform.identity
            arrowImage.frame.origin.x = -arrowTargetFrame.width
            arrowImage.alpha = 0.0
            magicButtonLabel.alpha = 0.0
            magicButtonLabel.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            UIView.animate(withDuration: duration) {
                self.arrowImage.alpha = 1.0
                self.arrowImage.frame = arrowTargetFrame
                self.magicButtonLabel.alpha = 1.0
                self.magicButtonLabel.transform = CGAffineTransform.identity
            }
        } else {
            let arrowTargetFrame = dummyFrame(dummy: arrowDummy).offsetBy(dx: -60, dy: 40)
            let transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 4))
            arrowImage.alpha = 1.0
            magicButtonLabel.alpha = 1.0
            UIView.animate(withDuration: duration) {
                self.arrowImage.alpha = 0.0
                self.arrowImage.frame = arrowTargetFrame
                self.arrowImage.transform = transform
                self.magicButtonLabel.alpha = 0.0
            }
        }
    }
}


extension ControlPanelViewController: QRCodeScanViewControllerDelegate {
    func qrCodeScanViewControllerCancel(_ viewController: QRCodeScanViewController) {
        print("Cancel")
        dismiss(animated: true, completion: nil)
    }
    
    func qrCodeScanViewController(_ viewController: QRCodeScanViewController, detectedText: String) {
        guard let host = host(from: detectedText) else {
            viewController.showInvalidQRWarning(qrText: detectedText)
            return
        }
        dismiss(animated: true, completion: nil)
        startClient(host: host)
    }
}


extension ControlPanelViewController: QRCodeDisplayViewControllerDelegate {
    func qrCodeDisplayViewControllerCancel(_ viewController: QRCodeDisplayViewController) {
        dismiss(animated: true, completion: nil)
    }
}


