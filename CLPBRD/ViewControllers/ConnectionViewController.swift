//
//  ConnectionViewController.swift
//  CLPBRD
//
//  Created by Александр Долоз on 20.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit


enum SyncDeviceType {
    case android
    case browser
    case ios
}


class SyncParticipant {
    var buffer: ContentBuffer
    var host: String
    var deviceType: SyncDeviceType?
    
    init(buffer: ContentBuffer, host: String, deviceType: SyncDeviceType? = nil) {
        self.buffer = buffer
        self.host = host
        self.deviceType = deviceType
    }
}


class ConnectionViewController: UIViewController {
//    var localSyncParticipant: SyncParticipant!
//    var remoteSyncParticipant: SyncParticipant!
    
    var localSyncParticipantView: SyncParticipantView!
    var remoteSyncParticipantView: SyncParticipantView!
    
    let socketClientService: SocketClientService
    let clipboardProviderService: ClipboardProviderService
    let host: String
    
    let localBuffer = ContentBuffer()
    let remoteBuffer = ContentBuffer()
    
    init(hostRepository: Repository<String>, socketClientService: SocketClientService, clipboardProviderService: ClipboardProviderService) {
        self.socketClientService = socketClientService
        self.clipboardProviderService = clipboardProviderService
        self.host = hostRepository.last!
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localSyncParticipantView = SyncParticipantView.instantiateFromNib()
        remoteSyncParticipantView = SyncParticipantView.instantiateFromNib()
        view.addSubview(localSyncParticipantView)
        view.addSubview(remoteSyncParticipantView)

        socketClientService.connect(host: host)
        socketClientService.onConnected = { [weak self] in
            self?.socketServiceConnected()
        }
        socketClientService.onReceivedText = { [weak self](text) in
            self?.receivedText(text: text)
        }
        localBuffer.content = clipboardProviderService.content
        clipboardProviderService.onContentChanged = { [weak self] in
            self?.clipboardContentChanged()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(enteredForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(localBufferUpdated), name: ContentBuffer.changeNotificationName, object: localBuffer)
        NotificationCenter.default.addObserver(self, selector: #selector(remoteBufferUpdated), name: ContentBuffer.changeNotificationName, object: remoteBuffer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localSyncParticipantView.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
        localSyncParticipantView.center = CGPoint(x: 160, y: 300)
        remoteSyncParticipantView.frame = CGRect(x: 0, y: 500, width: 120, height: 120)
        remoteSyncParticipantView.center = CGPoint(x: 160, y: 600)
        clipboardContentChanged()
        updateColors()
    }
    
    func enteredForeground() {
        socketClientService.connect(host: host)
        clipboardContentChanged()
        updateColors()
    }
    
    func socketServiceConnected() {
        connectParticipants()
    }
    
    func socketServiceDisconnnected() {
        print("Disconnected")
    }
    
    func connectParticipants() {
        localSyncParticipantView.host = getLocalIpAddress()
        remoteSyncParticipantView.host = host
    }
    
    func receivedText(text: String) {
        if remoteBuffer.content != text {
            remoteBuffer.content = text
        }
    }
    
    func participantView(for buffer: ContentBuffer) -> SyncParticipantView {
        switch buffer {
        case localBuffer: return localSyncParticipantView
        case remoteBuffer: return remoteSyncParticipantView
        default: fatalError("Unknown buffer \(buffer)")
        }
    }
    
    func clipboardContentChanged() {
        if clipboardProviderService.content != localBuffer.content {
            localBuffer.content = clipboardProviderService.content
        }
    }
    
    func updateColors() {
        localSyncParticipantView.set(color: localBuffer.hashColor, animated: false)
        remoteSyncParticipantView.set(color: remoteBuffer.hashColor, animated: false)
    }
    
    func localBufferUpdated() {
        localSyncParticipantView.set(color: localBuffer.hashColor)
        clipboardProviderService.content = localBuffer.content
    }
    
    func remoteBufferUpdated() {
        remoteSyncParticipantView.set(color: remoteBuffer.hashColor)
        guard let content = remoteBuffer.content else { return }
        socketClientService.send(text: content)
    }
    
    @IBAction func sendUpPressed(_ sender: Any) {
        remoteBuffer.send(to: localBuffer)
    }
    

    @IBAction func sendDownPressed(_ sender: Any) {
        localBuffer.send(to: remoteBuffer)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


