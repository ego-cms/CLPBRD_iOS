//
//  SyncServerDebugViewController.swift
//  CLPBRD
//
//  Created by Александр Долоз on 11.04.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit

class SyncServerDebugViewController: UIViewController {
    @IBAction func startServerPressed(_ sender: Any) {
        clipboardSyncServerService.start(port: 8080)
    }

    @IBAction func stopServerPressed(_ sender: Any) {
        clipboardSyncServerService.stop()
    }
    
    @IBAction func takeContentsPressed(_ sender: Any) {
        clipboardSyncServerService.takeUpdates()
    }
    
    @IBOutlet weak var clipboardContentsLabel: UILabel!
    
    var clipboardSyncServerService: ClipboardSyncServerService
    
    init(clipboardSyncServerService: ClipboardSyncServerService) {
        self.clipboardSyncServerService = clipboardSyncServerService
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clipboardSyncServerService.onUpdatesReceived = receivedUpdates
        clipboardSyncServerService.onStateChanged = stateChanged
        NotificationCenter.default.addObserver(self, selector: #selector(clipboardChanged), name: Notification.Name.UIPasteboardChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(clipboardChanged), name: Notification.Name.UIPasteboardRemoved, object: nil)
    }
    
    func clipboardChanged() {
        clipboardContentsLabel.text = UIPasteboard.general.string
    }
    
    func receivedUpdates() {
        print("Got updates")
    }
    
    func stateChanged(newState: ServerState) {
        print("State changed to: \(newState)")
        print("URL: \(String(describing: clipboardSyncServerService.serverURL))")
    }

}
