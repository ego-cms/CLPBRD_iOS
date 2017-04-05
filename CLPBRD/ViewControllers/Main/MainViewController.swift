import UIKit


class MainViewController: UIViewController {
    @IBOutlet weak var controlPanelContainer: UIView!
    
    var controlPanelViewController: ControlPanelViewController
    
    init(controlPanelViewController: ControlPanelViewController) {
        self.controlPanelViewController = controlPanelViewController
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        addChildViewController(controlPanelViewController)
        controlPanelViewController.didMove(toParentViewController: self)
        controlPanelViewController.view.frame = controlPanelContainer.bounds
        controlPanelContainer.addSubview(controlPanelViewController.view)
    }
}
