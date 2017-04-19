import UIKit


private let egoURL = URL(string: "http://ego-cms.com")!

class MainViewController: UIViewController {
    @IBOutlet weak var controlPanelContainer: UIView!
    
    @IBOutlet weak var usageDescriptionLabel: UILabel!
    @IBOutlet weak var madeByLabel: UILabel!
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
        usageDescriptionLabel.text = L10n.usageDescription.string
        madeByLabel.text = L10n.madeBy.string
    }
    
    @IBAction func logoPressed() {
        UIApplication.shared.open(egoURL, completionHandler: nil)
    }
}
