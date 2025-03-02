//
//  UpbitWebSocketService.swift
//  upbit
//
//  Created by 홍정연 on 2/28/25.
//

import Foundation
import Starscream
import RxSwift

class UpbitWebSocketService {
    private var socket: WebSocket?
    
    private let uuid = UUID().uuidString
    
    private let baseURL: URL = {
        guard let url = URL(string: "wss://api.upbit.com/websocket/v1") else {
            fatalError("유효하지 않은 base URL입니다.")
        }
        return url
    }()
    
    // MARK: WebSocket didReceive Event 주제
    let socketEventSubject: PublishSubject<WebSocketEventWrapper> = PublishSubject<WebSocketEventWrapper>()
    
    init() {
        var request = URLRequest(url: baseURL)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket?.delegate = self
    }
    
    // MARK: 웹소켓 요청
    func subscribeTo(types: [SocketRequestType], symbol: [String]) {
        guard let socket = self.socket else {
            print("WebSocket is not initialized")
            return
        }
        
        let subscription: [[String: Any]] = [
            ["ticket": uuid]
        ]
        
        // MARK: 웹소켓 요청이 복수이면 그만큼 Type 필드를 추가함
        let typeSubscriptions = types.map { type -> [String: Any] in
            return ["type": type.rawValue, "codes": symbol]
        }
        
        let jsonData = try! JSONSerialization.data(withJSONObject: subscription + typeSubscriptions)
        socket.write(data: jsonData)
    }
    
    // MARK: 웹소켓 연결
    func connect() {
        guard let socket = self.socket else {
            print("WebSocket is not initialized")
            return
        }
        socket.connect()
    }
    
    // MARK: 웹소켓 연결해제
    func disconnect() {
        guard let socket = self.socket else {
            print("WebSocket is not initialized")
            return
        }
        socket.disconnect()
    }
}

// MARK: - Place for WebSocketDelegate
extension UpbitWebSocketService: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        // MARK: Socket Event 방출
        self.socketEventSubject.onNext(WebSocketEventWrapper(event: event))
    }
}

// MARK: WebSocketEvent가 value 타입이 아니기 때문에 value 타입으로 만들기 위해 Wrapping함
class WebSocketEventWrapper {
    let event: WebSocketEvent
    
    init(event: WebSocketEvent) {
        self.event = event
    }
}
