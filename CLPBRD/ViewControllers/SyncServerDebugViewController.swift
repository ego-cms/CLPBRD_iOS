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
    }

    @IBAction func stopServerPressed(_ sender: Any) {
    }
    
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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
