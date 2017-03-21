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
    var localSyncParticipant: SyncParticipant!
    var remoteSyncParticipant: SyncParticipant!
    
    var localSyncParticipantView: SyncParticipantView!
    var remoteSyncParticipantView: SyncParticipantView!
    
    let socketClientService: SocketClientService
    let clipboardProviderService: ClipboardProviderService
    let host: String
    
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
        localSyncParticipantView.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
        remoteSyncParticipantView.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
        localSyncParticipantView.center = CGPoint(x: 150, y: 300)
        remoteSyncParticipantView.center = CGPoint(x: 150, y: 500)
        view.addSubview(localSyncParticipantView)
        view.addSubview(remoteSyncParticipantView)
        print(getIFAddresses())
        socketClientService.connect(host: host)
        socketClientService.onConnected = { [weak self] in
            self?.socketServiceConnected()
        }
        socketClientService.onReceivedText = { [weak self](text) in
            self?.receivedText(text: text)
        }
    }
    
    func socketServiceConnected() {
        connectParticipants()
    }
    
    func socketServiceDisconnnected() {
        print("Disconnected")
    }
    
    func connectParticipants() {
        let localBuffer = ContentBuffer()
        let remoteBuffer = ContentBuffer()
        localSyncParticipantView.hostAddressLabel.text = getLocalIpAddress()
        remoteSyncParticipantView.hostAddressLabel.text = host
        remoteSyncParticipant = SyncParticipant(buffer: remoteBuffer, host: host)
        localSyncParticipant = SyncParticipant(buffer: localBuffer, host: getLocalIpAddress() ?? "")
        
        NotificationCenter.default.addObserver(self, selector: #selector(localBufferUpdated), name: ContentBuffer.changeNotificationName, object: localBuffer)
        NotificationCenter.default.addObserver(self, selector: #selector(remoteBufferUpdated), name: ContentBuffer.changeNotificationName, object: remoteBuffer)
        localBuffer.content = clipboardProviderService.content
        clipboardProviderService.onContentChanged = { [weak self] in
            self?.clipboardContentChanged()
        }
    }
    
    func receivedText(text: String) {
        if remoteSyncParticipant.buffer.content != text {
            remoteSyncParticipant.buffer.content = text
        }
    }
    
    func clipboardContentChanged() {
        if clipboardProviderService.content != localSyncParticipant.buffer.content {
            localSyncParticipant.buffer.content = clipboardProviderService.content
        }
    }
    
    func localBufferUpdated() {
        UIView.animate(withDuration: 0.25) {
            self.localSyncParticipantView?.container.backgroundColor = self.localSyncParticipant.buffer.hashColor
        }
        clipboardProviderService.content = self.localSyncParticipant.buffer.content
    }
    
    func remoteBufferUpdated() {
        UIView.animate(withDuration: 0.25) {
            self.remoteSyncParticipantView?.container.backgroundColor = self.remoteSyncParticipant.buffer.hashColor
        }
        
        guard let content = self.remoteSyncParticipant.buffer.content else { return }
        socketClientService.send(text: content)
    }
    
    func bufferUpdated(notification: Notification) {
        guard let buffer = notification.object as? ContentBuffer else {
            return
        }
        let isLocalBuffer = buffer == localSyncParticipant.buffer
        let participantView = isLocalBuffer ? localSyncParticipantView : remoteSyncParticipantView
        if isLocalBuffer {
            
        }
        UIView.animate(withDuration: 0.25) { 
            participantView?.container.backgroundColor = buffer.hashColor
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


