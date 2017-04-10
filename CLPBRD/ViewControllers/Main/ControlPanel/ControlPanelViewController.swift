import UIKit
import Swinject


protocol ControlPanelViewControllerDelegate: class {
    func controlPanelViewController(_ cpVC: ControlPanelViewController, didChangeStateFrom: ControlPanelViewController.State, to: ControlPanelViewController.State)
    func controlPanelViewControllerDidPressOnButton(_ cpVC: ControlPanelViewController)
    func controlPanelViewControllerDidPressQRScanButton(_ cpVC: ControlPanelViewController)
    func controlPanelViewControllerDidPressOffButton(_ cpVC: ControlPanelViewController)
    func controlPanelViewControllerDidPressReceiveButton(_ cpVC: ControlPanelViewController)
}


func loadAndTranslatePath(fileName: String) -> UIBezierPath {
    let path = loadSVG(from: fileName)
    let origin = path.bounds.origin
    let transform = CGAffineTransform(translationX: -origin.x, y: -origin.y)
    path.apply(transform)
    return path
}


class ControlPanelViewController: UIViewController {
    lazy var expandedPath: UIBezierPath = loadAndTranslatePath(fileName: "buttons_expanded")
    lazy var collapsedPath: UIBezierPath = loadAndTranslatePath(fileName: "buttons_collapsed")
    var animationDuration = 0.25
    
    private(set) var state: State = .off {
        didSet {
            updateContainerVisibility()
        }
    }
    
    @IBOutlet weak var toggleButton: RoundButton!
    @IBOutlet weak var scanQRButton: RoundButton!
    var buttonBackgroundLayer = CAShapeLayer()
    
    @IBOutlet weak var buttonBackgroundOffDummy: UIView!
    @IBOutlet weak var buttonBackgroundOnDummy: UIView!
    @IBOutlet weak var scanQROffDummy: UIView!
    @IBOutlet weak var scanQROnDummy: UIView!
    @IBOutlet weak var toggleOffDummy: UIView!
    @IBOutlet weak var toggleOnDummy: UIView!
    
    @IBOutlet weak var serverInfoContainer: UIView!
    @IBOutlet weak var serverAddressLabel: UILabel!
    @IBOutlet weak var offInfoContainer: UIView!
    
    var serverIp: String?
    var receivedText: String?
    var alreadyRecognized = false
    
    var socketClientService: SocketClientService
    var clipboardProviderService: ClipboardProviderService
    var appStateService: AppStateService
    var httpServerService: HTTPServerService
    var socketServerService: SocketServerService
    
    unowned var container: Container
    
    init(
        container: Container,
        socketClientService: SocketClientService,
        clipboardProviderService: ClipboardProviderService,
        appStateService: AppStateService,
        httpServerService: HTTPServerService,
        socketServerService: SocketServerService
    ) {
        self.container = container
        self.socketClientService = socketClientService
        self.appStateService = appStateService
        self.clipboardProviderService = clipboardProviderService
        self.httpServerService = httpServerService
        self.socketServerService = socketServerService
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func scanQRPressed() {
        print("Pressed")
        let qrCodeScanViewController = container.resolve(QRCodeScanViewController.self)!
        qrCodeScanViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: qrCodeScanViewController)
        navigationController.modalPresentationStyle = .overFullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.sendSubview(toBack: scanQRButton)
        view.sendSubview(toBack: buttonBackgroundOffDummy)
//        buttonBackgroundLayer.isHidden = true
        buttonBackgroundOffDummy.isHidden = true
        //buttonBackgroundLayer.anchorPoint = CGPoint.zero
        scanQRButton.highlightColor = Colors.scanQRButtonHighlighted.color
        scanQRButton.normalColor = Colors.scanQRButtonNormal.color
        toggleButton.highlightColor = Colors.toggleButtonOffHighlighted.color
        toggleButton.normalColor = Colors.toggleButtonOffNormal.color
        view.layer.addSublayer(buttonBackgroundLayer)
        buttonBackgroundLayer.zPosition = -1.0
        buttonBackgroundLayer.anchorPoint = CGPoint(x: 1.0, y: 0.0)
        updateContainerVisibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resizePaths()
        setupButtons()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resizePaths()
        setupButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resizePaths()
    }
    
    func updateContainerVisibility() {
        let visible = state == .off ? offInfoContainer : serverInfoContainer
        let invisible = state != .off ? offInfoContainer : serverInfoContainer
        UIView.animate(withDuration: animationDuration) { 
            visible?.alpha = 1.0
            invisible?.alpha = 0.0
        }
    }
    
    func setupButtons() {
        DispatchQueue.main.async {
            self.toggleButton.frame = self.toggleButtonFrame(for: self.state)
            self.scanQRButton.frame = self.qrButtonFrame(for: self.state)
        }
    }
    
    @IBAction func toggleButtonPressed(_ sender: Any) {
        switch state {
        case .clientOn:
            serverIp = nil
            socketClientService.disconnect()
            updateState(to: .off)
        case .clientGotUpdates:
            clipboardProviderService.content = receivedText
            updateState(to: .clientOn)
        default:
            print("Button in state \(state). can't handle it yet")
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
    
    func qrButtonFrame(for state: State) -> CGRect {
        switch state {
        case .off: return dummyFrame(dummy: scanQROffDummy)
        default: return dummyFrame(dummy: scanQROnDummy)
        }
    }
    
    func qrButtonAlpha(for state: State) -> CGFloat {
        switch state {
        case .off:
            return 1.0
        default:
            return 0.0
        }
    }
    
    func buttonBackgroundLayerPath(for state: State) -> UIBezierPath {
        switch state {
        case .off: return expandedPath
        default: return collapsedPath
        }
    }
    

    func buttonBackgroundLayerFrame(for state: State) -> CGRect {
        switch state {
        case .off:
            return dummyFrame(dummy: buttonBackgroundOffDummy)
        default:
            return dummyFrame(dummy: buttonBackgroundOnDummy)
        }
    }
    
    func buttonBackgroundLayerPosition(for state: State) -> CGPoint {
        let frame = buttonBackgroundLayerFrame(for: state)
        return CGPoint(x: frame.minX, y: frame.minY)
    }
    
    func buttonBackgroundLayerColor(for state: State) -> UIColor {
        if state.isOn { return Colors.buttonGroupCollapsed.color }
        if state.gotUpdates { return Colors.buttonGroupGotUpdates.color }
        return Colors.buttonGroupExpanded.color
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
        if state.isOn { return "ВЫКЛ." }
        if state.gotUpdates { return "↓" }
        return "ВКЛ."
    }
    
    func resizePaths() {
        let transform = expandedPath.scale(toFit: buttonBackgroundOffDummy.frame.size)
        expandedPath.apply(transform)
        collapsedPath.apply(transform)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        buttonBackgroundLayer.path = buttonBackgroundLayerPath(for: state).cgPath
//        buttonBackgroundLayer.frame = buttonBackgroundLayerFrame(for: state)
        buttonBackgroundLayer.position = buttonBackgroundLayerPosition(for: state)
        buttonBackgroundLayer.fillColor = buttonBackgroundLayerColor(for: state).cgColor
        CATransaction.commit()
    }
    
    func animateButtonBackgroundLayer(to state: State) {
        
    }
    
    func updateState(to state: State, animated: Bool = true) {
        let duration = animated ? animationDuration : 0.0
        toggleButton.setTitle(toggleButtonTitle(for: state), for: .normal)
        
        UIView.animate(withDuration: duration, animations: {
            self.scanQRButton.frame = self.qrButtonFrame(for: state)
            self.toggleButton.normalColor = self.toggleButtonNormalColor(for: state)
            self.toggleButton.highlightColor = self.toggleButtonHighlightedColor(for: state)
            self.scanQRButton.alpha = self.qrButtonAlpha(for: state)
        }, completion: { _ in
            self.buttonBackgroundLayer.position = self.buttonBackgroundLayerPosition(for: state)
        })
        buttonBackgroundLayer.path = buttonBackgroundLayerPath(for: state).cgPath
        buttonBackgroundLayer.fillColor = buttonBackgroundLayerColor(for: state).cgColor
        buttonBackgroundLayer.position = buttonBackgroundLayerPosition(for: state)
        let morphing = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
        //morphing.fromValue = buttonBackgroundLayerPath(for: self.state)
        morphing.fromValue = buttonBackgroundLayerPath(for: self.state).cgPath
        morphing.toValue = buttonBackgroundLayerPath(for: state).cgPath
        //morphing.beginTime = duration
        morphing.duration = duration
        let changeColor = CABasicAnimation(keyPath: "fillColor")
        //changeColor.fromValue = state.color.cgColor
        changeColor.toValue = buttonBackgroundLayerColor(for: state).cgColor
        changeColor.duration = duration
        /*let group = CAAnimationGroup()
        group.duration = ButtonBackgroundView.animationDuration
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        group.animations = [morphing, changeColor]*/
        //backgroundLayer.add(group, forKey: "state_animation")
        let move = CABasicAnimation(keyPath: "position")
        move.toValue = NSValue(cgPoint: buttonBackgroundLayerPosition(for: state))
        move.beginTime = CACurrentMediaTime() + duration
        move.duration = duration
        buttonBackgroundLayer.add(changeColor, forKey: "change_color")
        buttonBackgroundLayer.add(morphing, forKey: "morphing")
        buttonBackgroundLayer.add(move, forKey: "move")
        UIView.animate(withDuration: duration, delay: duration, options: [], animations: { 
            self.toggleButton.frame = self.toggleButtonFrame(for: state)
        }, completion: nil)
        self.state = state
    }
}


extension ControlPanelViewController: QRCodeScanViewControllerDelegate {
    func qrCodeScanViewControllerCancel(_ viewController: QRCodeScanViewController) {
        print("Cancel")
        dismiss(animated: true, completion: nil)
    }
    
    func qrCodeScanViewController(_ viewController: QRCodeScanViewController, detectedText: String) {
        if alreadyRecognized { return }
        guard let host = host(from: detectedText) else {
            viewController.showInvalidQRWarning(qrText: detectedText)
            return
        }
        alreadyRecognized = true
        dismiss(animated: true, completion: nil)
        serverIp = host
        socketClientService.connect(host: host)
        socketClientService.onConnected = socketClientServiceConnected
        socketClientService.onDisconnected = socketClientServiceDisconnected
        socketClientService.onReceivedText = socketClientServiceReceivedText
        clipboardProviderService.onContentChanged = clipboardContentChanged
        appStateService.onAppEnterForeground = appEnteredForeground
    }
}


extension ControlPanelViewController {
    func socketClientServiceConnected() {
        updateState(to: .clientOn)
    }
    
    func socketClientServiceDisconnected(error: Error?) {
        updateState(to: .off)
        alreadyRecognized = false
        if let error = error {
            print(error)
            if let host = serverIp {
                socketClientService.connect(host: host)
            }
        }
//        serverIp = nil
    }
    
    func socketClientServiceReceivedText(text: String) {
        if text != "" && text != clipboardProviderService.content {
            receivedText = text
            updateState(to: .clientGotUpdates)
        }
    }
    
    func clipboardContentChanged() {
        guard
            let content = clipboardProviderService.content,
            content != receivedText
        else {
            return
        }
        socketClientService.send(text: content)
    }
    
    func appEnteredForeground() {
        if let host = serverIp {
            socketClientService.connect(host: host)
        }
    }
}


extension ControlPanelViewController {
    enum State {
        case off
        case clientOn
        case clientGotUpdates
        case serverOn
        case serverGotUpdates
        
        var gotUpdates: Bool {
            return self == .clientGotUpdates || self == .serverGotUpdates
        }
        
        var isOff: Bool {
            return self == .off
        }
        
        var isOn: Bool {
            return self == .clientOn || self == .serverOn
        }
    }
}


