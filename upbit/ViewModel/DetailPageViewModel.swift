//
//  DetailPageViewModel.swift
//  upbit
//
//  Created by 홍정연 on 4/1/25.
//

import Foundation
import RxSwift
import RxCocoa
import Starscream

class DetailPageViewModel {
    
    // MARK: disposeBag
    private var disposeBag = DisposeBag()
    
    // MARK: 업비트 웹 소켓 서비스
    private let webSocketService = UpbitWebSocketService()
    
    // MARK: - Place for Input
    // MARK: 선택된 코인 마켓 정보
    let marketInfo: MarketInfo
    
    // MARK: - Place for Output
    // MARK: 실시간 현재가 정보
    let tickerSubejct: PublishSubject<SocketTicker> = PublishSubject<SocketTicker>()
    
    // MARK: 실시간 호가 정보
    let orderbookSubejct: PublishSubject<Orderbook> = PublishSubject<Orderbook>()
    
    
    init(marketInfo: MarketInfo) {
        self.marketInfo = marketInfo
        self.bind()
    }
    
    private func bind() {
        // MARK: 웹소켓 서비스의 웹소켓 이벤트 구독
        self.webSocketService.socketEventSubject
            .asObservable()
            .subscribe(onNext: { [weak self] eventWrapper in
                guard let self = self else { return }
                self.didReceiveEvent(event: eventWrapper.event)
            }).disposed(by: disposeBag)
    }
    
    // MARK: 선택된 코인 Ticker WebSocket 요청
    private func requestTicker() {
        let code = self.marketInfo.market
        // MARK: 현재가, 호가 요청
        self.webSocketService.subscribeTo(types: [.ticker, .orderbook], symbol: [code])
    }
    
    // MARK: WebSocketDelegate에서 발생하는 WebSocket Event 처리
    private func didReceiveEvent(event: WebSocketEvent) {
        
        let className = String(describing: self)
        
        switch event {
            
            // MARK: 소켓이 연결됨
        case .connected(let headers):
            print("\(className): websocket is connected: \(headers)")
            // MARK: 선택된 코인 Ticker 요청
            self.requestTicker()
            
            // MARK: 소켓이 연결 해제됨
        case .disconnected(let reason, let code):
            print("\(className): websocket is disconnected: \(reason) with code: \(code)")
            
            // MARK: 텍스트 메세지를 받음
        case .text(let string):
            print("\(className): Received text: \(string)")
            
            // MARK: 이진(binary) 데이터를 받음
        case .binary(let data):
            self.handleSocketData(data: data)
            break
            
            // MARK: 핑 메세지를 받음
        case .ping(_):
            print("\(className): ping")
            break
            
            // MARK: 퐁 메세지를 받음
        case .pong(_):
            print("\(className): pong")
            break
            
            // MARK: 연결의 안정성이 변경됨
        case .viabilityChanged(_):
            print("\(className): viabilityChanged")
            break
            
            // MARK: 재연결이 제안됨
        case .reconnectSuggested(_):
            print("\(className): reconnectSuggested")
            break
            
            // MARK: 소켓이 취소됨
        case .cancelled:
            print("\(className): cancelled")
            break
            
            // MARK: 에러가 발생함
        case .error(let error):
            print("\(className): error: \(error!.localizedDescription)")
            break
            
            // MARK: 피어가 연결을 종료함
        case .peerClosed:
            print("\(className): peerClosed")
            break
        }
    }
    
    // MARK: 웹소켓으로부터 받은 바이너리 데이터 핸들링
    private func handleSocketData(data: Data) {
        if let ticker: SocketTicker = SocketTicker.parseData(data) {
            self.tickerSubejct.onNext(ticker)
        }
        
        if let orderbook: Orderbook = Orderbook.parseData(data) {
            self.orderbookSubejct.onNext(orderbook)
        }
    }
    
    // MARK: 웹 소켓 연결
    func connectWebSocket() {
        self.webSocketService.connect()
    }
    
    // MARK: 웹 소켓 연결 해제
    func disconnectWebSocket() {
        self.webSocketService.disconnect()
    }
}
