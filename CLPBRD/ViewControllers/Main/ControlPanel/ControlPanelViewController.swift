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
    
    @IBOutlet weak var serverInfoContainer: UIView!
    @IBOutlet weak var serverAddressLabel: UILabel!
    @IBOutlet weak var offInfoContainer: UIView!
    @IBOutlet weak var showQRButton: UIButton!
    @IBOutlet weak var addressDescriptionLabel: UILabel!
    
    @IBOutlet weak var buttonBackgroundView: ButtonBackgroundView!
    
    @IBOutlet weak var promptToScanLabel: UILabel!
    var receivedText: String?
    var alreadyRecognized = false
    
    var localServerURL: URL? {
        didSet {
            serverAddressLabel.text = clipboardSyncServerService.serverURL?.absoluteString ?? ""
        }
    }
    
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
        clipboardSyncServerService.onStateChanged = clipboardSyncServiceStateChanged
        clipboardSyncServerService.onUpdatesReceived = updatesReceived
        clipboardSyncClientService.onConnected = clientConnected
        clipboardSyncClientService.onUpdatesReceived = clientReceivedUpdates
        clipboardSyncClientService.onDisconnected = clientDisconnected
    }
    
    func clipboardSyncServiceStateChanged(newState: ServerState) {
        if newState == .off {
            updateState(to: .off)
        } else {
            updateState(to: .serverOn)
        }
    }
    
    func updatesReceived() {
        updateState(to: .serverGotUpdates)
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
        updateContainerVisibility(animated: false)
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
            self.updateButtonFrames()
            self.buttonBackgroundView.frame = self.dummyFrame(dummy: self.buttonBackgroundOffDummy)
            self.buttonBackgroundView.heightInExpandedState = self.buttonBackgroundView.frame.height
        }
    }
//
    // MARK: Client callbacks
    
    func clientConnected() {
        updateState(to: .clientOn)
    }
    
    func clientReceivedUpdates() {
        updateState(to: .clientGotUpdates)
    }
    
    func clientDisconnected(error: Error?) {
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
    
    @IBAction func toggleButtonPressed(_ sender: Any) {
        switch state {
        case .serverOn:
            clipboardSyncServerService.stop()
            clipboardSyncClientService.disconnect()
            updateState(to: .off)
        case .serverGotUpdates:
            clipboardSyncServerService.takeUpdates()
            makeNotification(clipboardContent: UIPasteboard.general.string ?? "")
            updateState(to: .serverOn)
            
        case .clientOn:
            clipboardSyncServerService.stop()
            clipboardSyncClientService.disconnect()
            updateState(to: .off)
        case .clientGotUpdates:
            clipboardSyncClientService.takeUpdates()
            makeNotification(clipboardContent: UIPasteboard.general.string ?? "")
            updateState(to: .clientOn)
        case .off:
            clipboardSyncClientService.disconnect()
            clipboardSyncServerService.start(port: 8080)
            localServerURL = clipboardSyncServerService.serverURL
        }
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
        if state.isOff { return dummyFrame(dummy: buttonBackgroundOffDummy) }
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
        log.verbose("Transitioning from \(oldState) to \(newState) animated \(animated)")
        guard newState != oldState else { return }
        self.addressDescriptionLabel.text = self.addressDescription(for: newState)
        self.showQRButton.isHidden = newState.isClient
        let multiplier: CGFloat = (newState.isOff ? 1.0 : 0.0) - (oldState.isOff ? 1.0 : 0.0)
        let deltaX = multiplier * toggleButtonPositionsDistance
        
        let duration = animated ? animationDuration : 0.0
        
        let shapePathAnimationTrigger = {
            log.verbose("shape path animation")
            self.buttonBackgroundView.changeState(to: newState.buttonBackgroundViewState, animated: animated)
        }
        
        let shapePositionAnimationTrigger = {
            log.verbose("shape position animation")
            UIView.animate(withDuration: duration) {
                self.buttonBackgroundView.center.x += deltaX
            }
        }
        
        let scanQRButtonAnimationTrigger = {
            log.verbose("scan qr animation")
            UIView.animate(withDuration: duration) {
                self.scanQRButton.frame = self.qrButtonFrame(for: newState)
                self.scanQRButton.alpha = self.qrButtonAlpha(for: newState)
            }
        }
        
        let toggleButtonPositionAnimationTrigger = {
            log.verbose("toggle button animation")
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
        performTransition(from: self.state, to: newState)
        self.state = newState
    }
    
    func makeNotification(clipboardContent: String) {
        showLocalNotification(text: clipboardContent)
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
        clipboardSyncClientService.connect(host: host, port: 8080)
    }
}


extension ControlPanelViewController: QRCodeDisplayViewControllerDelegate {
    func qrCodeDisplayViewControllerCancel(_ viewController: QRCodeDisplayViewController) {
        dismiss(animated: true, completion: nil)
    }
}


