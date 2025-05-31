//
//  UpbitWebSocketService.swift
//  upbit
//
//  Created by 홍정연 on 2/28/25.
//

import Foundation
import Starscream
import RxSwift
import CryptoKit
import SwiftJWT

// MARK: 웹소켓 요청의 종류(인증이 필요없는 요청, 인증이 필요한 요청)
enum SocketSource {
    case `public`
    case `private`
}

// MARK: public 요청과, private 요청을 구분 짓기 위해 source 필드를 추가
struct WebSocketEventWrapper {
    // MARK: 방출은 하나의 이벤트로 하지만, 출처가 어떤 소켓인지 알아야 분기처리하거나 문제 발생시 해당 소켓을 처리하기 위함
    let source: SocketSource
    let event: WebSocketEvent
}

class UpbitWebSocketService {
    
    // MARK: Public 타입의 Endpoint를 담당하는 웹소켓(인증이 필요하지 않음)
    private var publicSocket: WebSocket?
    
    // MARK: Private 타입의 Endpoint를 담당하는 웹소켓(인증이 필요함)
    private var privateSocket: WebSocket?
    
    // MARK: Public ticket에 할당될 요청자의 식별값(유니크한 값)
    private let publicUUID = UUID().uuidString
    
    // MARK: Private ticket에 할당될 요청자의 식별값(유니크한 값)
    private let privateUUID = UUID().uuidString
    
    // MARK: Public Endpoint URL
    private let publicURL: URL = {
        guard let url = URL(string: "wss://api.upbit.com/websocket/v1") else {
            fatalError("유효하지 않은 public base URL입니다.")
        }
        return url
    }()
    
    // MARK: Private Endpoint URL
    private let privateURL: URL = {
        guard let url = URL(string: "wss://api.upbit.com/websocket/v1/private") else {
            fatalError("유효하지 않은 private base URL입니다.")
        }
        return url
    }()
    
    
    // MARK: WebSocket didReceive Event 주제(public socket + private socket 이벤트 방출)
    let socketEventSubject: PublishSubject<WebSocketEventWrapper> = PublishSubject<WebSocketEventWrapper>()
    
    
    init() {
        // MARK: public 소켓 연결
        do {
            var publicRequest = URLRequest(url: publicURL)
            publicRequest.timeoutInterval = 5
            let socket = WebSocket(request: publicRequest)
            socket.delegate = self
            self.publicSocket = socket
        }
        
        do {
            // MARK: private 소켓 연결(인증 필요)
            let jwtToken = generateWebSocketJWT()
            
            var privateRequest = URLRequest(url: privateURL)
            privateRequest.timeoutInterval = 5
            privateRequest.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "authorization")
            let socket = WebSocket(request: privateRequest)
            socket.delegate = self
            self.privateSocket = socket
        }
    }
    
    // MARK: 웹소켓 요청
    func subscribeTo(types: [SocketRequestType], symbol: [String]) {
        
        // MARK: Public(인증이 필요 없는 요청)
        let publicTypes = types.filter { !$0.requiresAuth }
        if !publicTypes.isEmpty {
            var payload: [[String: Any]] = [["ticket": publicUUID]]
            payload += publicTypes.map { ["type": $0.rawValue, "codes": symbol] }
            let data = try! JSONSerialization.data(withJSONObject: payload)
            publicSocket?.write(data: data)
        }
        
        // MARK: Private(인증이 필요한 요청)
        let privateTypes = types.filter { $0.requiresAuth }
        if !privateTypes.isEmpty {
            var payload: [[String: Any]] = [["ticket": privateUUID]]
            payload += privateTypes.map { ["type": $0.rawValue, "codes": symbol] }
            let data = try! JSONSerialization.data(withJSONObject: payload)
            privateSocket?.write(data: data)
        }
    }
    
    // MARK: WebSocket JWT 생성
    private func generateWebSocketJWT() -> String {
        let payload = Payload(access_key: UpbitApiService.accessKey,
                              nonce: UUID().uuidString)
        var jwt = JWT(claims: payload)
        return try! jwt.sign(using: .hs256(key: .init(Data(UpbitApiService.secretKey.utf8))))
    }
    
    // MARK: 웹소켓 연결
    func connect() {
        self.publicSocket?.connect()
        self.privateSocket?.connect()
    }
    
    // MARK: 웹소켓 연결해제
    func disconnect() {
        self.publicSocket?.disconnect()
        self.privateSocket?.disconnect()
    }
}

// MARK: - Place for WebSocketDelegate
extension UpbitWebSocketService: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        
        // MARK: Socket Event 방출
        // MARK: 어느 소켓에서 온 이벤트인지 identity 비교로 판단
        let source: SocketSource
        if let ws = client as? WebSocket, ws === privateSocket {
            source = .private
        } else {
            source = .public
        }
        // MARK: 소켓 이벤트 방출
        socketEventSubject.onNext(WebSocketEventWrapper(source: source, event: event))
    }
}
