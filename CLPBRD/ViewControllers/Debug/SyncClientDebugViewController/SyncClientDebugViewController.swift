//
//  SyncClientDebugViewController.swift
//  CLPBRD
//
//  Created by Александр Долоз on 12.04.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit

class SyncClientDebugViewController: UIViewController {
    private var clipboardSyncClientService: ClipboardSyncClientService
    
    init(clipboardSyncClientService: ClipboardSyncClientService) {
        self.clipboardSyncClientService = clipboardSyncClientService
        clipboardSyncClientService.onConnected = {
            print("Client connected")
        }
        clipboardSyncClientService.onDisconnected = { error in
            print("Client disconnected with \(String(describing: error))")
        }
        clipboardSyncClientService.onUpdatesReceived = {
            print("Got updates")
        }
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
    }
    
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBAction func connectPressed(_ sender: Any) {
        clipboardSyncClientService.connect(host: addressTextField.text!, port: 8080)
    }
    
    @IBAction func disconnectPressed(_ sender: Any) {
        clipboardSyncClientService.disconnect()
    }
    
    @IBAction func takeUpdatesPressed(_ sender: Any) {
        clipboardSyncClientService.takeUpdates()
    }
    
    @IBOutlet weak var clipboardTextField: UILabel!
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(clipboardChanged), name: Notification.Name.UIPasteboardChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(clipboardChanged), name: Notification.Name.UIPasteboardRemoved, object: nil)
    }
    
    func clipboardChanged() {
        clipboardTextField.text = UIPasteboard.general.string
    }
}
