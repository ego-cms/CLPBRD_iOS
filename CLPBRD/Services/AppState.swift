//
//  AppState.swift
//  CLPBRD
//
//  Created by Александр Долоз on 17.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit


final class AppState: NSObject, AppStateService {
    var onAppEnterForeground: VoidClosure = {}
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(enteredForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func enteredForeground() {
        onAppEnterForeground()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
