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
    // MARK: 내가 보유한 자산 + 현재가 리스트
    let accountTickerRelay: BehaviorRelay<[AccountTicker]> = BehaviorRelay(value: [])
    
    // MARK: 내가 보유한 원화
    let accountKRWSubject: PublishSubject<Account> = PublishSubject<Account>()
    
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
                // MARK: 보유한 자산이 없으면 프로세스 종료
                guard let self = self, !accounts.isEmpty else { return }
                
                // MARK: 원화 자산은 따로 방출
                if let accountKRW = accounts.first(where: { $0.currency == "KRW" }) {
                    self.accountKRWSubject.onNext(accountKRW)
                }
                
                // MARK: 1. 거래 가능한 마켓 정보 가져오기(자산별 현재가 검색시, 업비트에서 지원하지 않는 코인 소지시 404에러 방출함)
                UpbitApiService.request(endpoint: .marketAll(is_details: true), method: .get) { [weak self] (result: Result<[MarketInfo], Error>) in
                    guard let self = self else { return }
                    switch result {
                    case .success(let markets):
                        
                        // MARK: 업비트에서 지원하는 마켓 코드 Set
                        let supportedMarkets = Set(markets.map { $0.market })
                        
                        // MARK: 업비트에서 지원하는 보유한 자산의 코드 String -> 예시: "KRW-BTC,KRW-DOGE,..."
                        let codes = accounts
                            .filter { $0.currency != "KRW" }
                            .map { "\($0.unit_currency)-\($0.currency)" }
                            .filter { supportedMarkets.contains($0) }
                            .joined(separator: ",")
                        
                        // MARK: 원화를 제외한 코드가 없다면 프로세스 종료
                        guard !codes.isEmpty else { return }
                        
                        // MARK: 2. 자산별 현재가 가져오기
                        UpbitApiService.request(endpoint: .ticker(markets: codes), method: .get) { [weak self] (result: Result<[ApiTicker], Error>) in
                            guard let self = self else { return }
                            switch result {
                            case .success(let tickers):
                                // MARK: Account와 ApiTicker를 결합하여 AccountTicker 배열 생성
                                let accountTickers: [AccountTicker] = accounts.compactMap { account in
                                    // MARK: 원화는 Ticker 정보가 없으므로 별도로 처리
                                    guard account.currency != "KRW" else { return nil }
                                    let marketCode = "\(account.unit_currency)-\(account.currency)"
                                    
                                    // MARK: 매칭된 한글명, 현재가 추출
                                    guard let marketInfo = markets.first(where: { $0.market == marketCode }), let ticker = tickers.first(where: { $0.market == marketCode }) else { return nil }
                                    return AccountTicker(marketInfo: marketInfo, account: account, ticker: ticker)
                                }
                                
                                //MARK: AccountRelay 방출
                                self.accountTickerRelay.accept(accountTickers)
                                
                                // MARK: WebSocket 현재가(Ticker) 조회
                                let codeArray = codes.components(separatedBy: ",")
                                self.webSocketService.subscribeTo(types: [.ticker], symbol: codeArray)
                                break
                                
                            case .failure(let error):
                                print(error.localizedDescription)
                                self.messageSubject.onNext(error.localizedDescription)
                                break
                            }
                        }
                        break
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        self.messageSubject.onNext(error.localizedDescription)
                    }
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
        // MARK: 최신 AccountTicker
        var currentTickers = accountTickerRelay.value
        
        for (index, accountTicker) in currentTickers.enumerated() {
            let marketCode = "\(accountTicker.account.unit_currency)-\(accountTicker.account.currency)"
            if marketCode == ticker.code {
                // MARK: code가 일치하면 ticker 업데이트
                let updatedAccountTicker = AccountTicker(marketInfo: accountTicker.marketInfo, account: accountTicker.account, ticker: ticker)
                currentTickers[index] = updatedAccountTicker
            }
        }
        accountTickerRelay.accept(currentTickers)
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
