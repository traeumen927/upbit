//
//  AccountViewModel.swift
//  upbit
//
//  Created by 홍정연 on 2/17/25.
//

import Foundation
import RxSwift
import RxCocoa
import Starscream


class AccountViewModel {
    
    // MARK: disposeBag
    private var disposeBag = DisposeBag()
    
    // MARK: 업비트 웹 소켓 서비스
    private let webSocketService = UpbitWebSocketService()
    
    // MARK: - Place for Output
    // MARK: 내가 보유한 자산 리스트
    let accountSubject: BehaviorSubject<[Account]> = BehaviorSubject(value: [])
    
    // MARK: 내가 보유한 코인 ticker
    let tickerRelay: BehaviorRelay<[SocketTicker]> = BehaviorRelay(value: [])
    
    // MARK: 메세지 주제
    let messageSubject: PublishSubject<String> = PublishSubject<String>()
    
    init() {
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
        
        // MARK: 보유 자산 구독
        AccountManager.shared.accountsObservable
            .subscribe(onNext: { [weak self] accounts in
                guard let self = self else { return }
                
                // MARK: 보유자산 방출
                self.accountSubject.onNext(accounts)
                
                // MARK: 보유원화를 제외한 자산의 마켓 코드 배열(currency가 KRW면 원화)
                let codes = accounts.filter({$0.currency != "KRW"}).map { "\($0.unit_currency)-\($0.currency)"}
                
                /*
                 codes의 예시
                 ["KRW-BTC", "KRW-DOGE", "KRW-STORJ", "KRW-EOSDAC", "KRW-GAS", "KRW-HORUS", "KRW-ADD", "KRW-MEETONE", "KRW-CHL", "KRW-BLACK", "KRW-STPT", "KRW-SHIB"]
                 */
                
                // MARK: 원화를 제외한 자산(코인)이 있다면 현재가 조회
                if !codes.isEmpty {
                    // MARK: 현재가(Ticker) 조회
                    self.webSocketService.subscribeTo(types: [.ticker], symbol: codes)
                }
            }).disposed(by: disposeBag)
    }
    
    // MARK: 전체 계좌 조회
    private func fetchAccount() {
        // MARK: 계좌 싱글톤 객체
        let accountManager = AccountManager.shared
        
        // MARK: 계좌 싱글톤 계좌목록 최신화
        accountManager.reload()
    }
    
    // MARK: tickerRelay 업데이트
    private func updateTicker(with ticker: SocketTicker) {
        var tickers = self.tickerRelay.value
        
        if let index = tickers.firstIndex(where: { $0.code == ticker.code }) {
            tickers[index] = ticker
        } else {
            tickers.append(ticker)
        }
        
        // MARK: 업데이트된 ticker Relay 방출
        self.tickerRelay.accept(tickers)
    }
    
    
    
    // MARK: WebSocketDelegate에서 발생하는 WebSocket Event 처리
    private func didReceiveEvent(event: WebSocketEvent) {
        
        let className = String(describing: self)
        
        switch event {
            
            // MARK: 소켓이 연결됨
        case .connected(let headers):
            print("\(className): websocket is connected: \(headers)")
            // MARK: 전체 계좌 조회
            self.fetchAccount()
            
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
            self.updateTicker(with: ticker)
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
