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
    
    // MARK: 인증이 필요 없는 요청을 담당하는 소켓
    private var publicSocket: WebSocket?
    
    // MARK: 인증이 필요한 요청을 담당하는 소켓
    private var privateSocket: WebSocket?
    
    private let uuid = UUID().uuidString
    
    // MARK: 기본 URL
    private let publicURL: URL = {
        guard let url = URL(string: "wss://api.upbit.com/websocket/v1") else {
            fatalError("유효하지 않은 base URL입니다.")
        }
        return url
    }()
    
    // MARK: 인증이 필요한 private URL
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
        var publicRequest = URLRequest(url: publicURL)
        publicRequest.timeoutInterval = 5
        publicSocket = WebSocket(request: publicRequest)
        publicSocket?.delegate = self
        
        // MARK: private 소켓 연결
        var privateRequest = URLRequest(url: privateURL)
        privateRequest.timeoutInterval = 5
        privateSocket = WebSocket(request: privateRequest)
        privateSocket?.delegate = self
    }
    
    // MARK: 웹소켓 요청
    func subscribeTo(types: [SocketRequestType], symbol: [String]) {
        
        // MARK: 티켓 생성
        let subscription: [[String: Any]] = [
            ["ticket": uuid]
        ]
        
        // MARK: Public(인증이 필요 없는 요청)
        let publicTypes = types.filter { !$0.requiresAuth }
        if !publicTypes.isEmpty {
            let publicPayload = subscription +
            publicTypes.map { ["type": $0.rawValue, "codes": symbol] }
            let data = try! JSONSerialization.data(withJSONObject: publicPayload)
            self.publicSocket?.write(data: data)
        }
        
        // MARK: Private(인증이 필요한 요청)
        let privateTypes = types.filter { $0.requiresAuth }
        if !privateTypes.isEmpty {
            var privatePayload = subscription +
            privateTypes.map { ["type": $0.rawValue, "codes": symbol] }
            
            // MARK: 인증 토큰 추가
            let token = generateWebSocketJWT()
            privatePayload.append([
                "type": "authorization",
                "token": "Bearer \(token)"
            ])
            
            let data = try! JSONSerialization.data(withJSONObject: privatePayload)
            self.privateSocket?.write(data: data)
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
        socketEventSubject.onNext(.init(source: source, event: event))
    }
}
