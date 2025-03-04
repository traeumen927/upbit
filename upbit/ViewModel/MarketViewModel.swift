//
//  MarketViewModel.swift
//  upbit
//
//  Created by 홍정연 on 2/17/25.
//

import Foundation
import RxSwift
import RxCocoa
import Starscream

class MarketViewModel {
    
    // MARK: disposeBag
    private let disposeBag = DisposeBag()
    
    // MARK: 업비트 웹 소켓 서비스
    private let webSocketService = UpbitWebSocketService()
    
    // MARK: 내부 관리 MarketTickers
    private var marketTickers: [MarketTicker] = []
    
    // MARK: 특정 조건에 따라 사용될 현재 MarketTickers
    private var filteredTickers: [MarketTicker] = []
    
    // MARK: - Place for Input
    // MARK: 코인 정렬 순서 옵션, 초기값은 24시간 누적 거래량
    var sortOption: SortOption = .volume24Descending {
        didSet {
            // MARK: 옵션 변경 시 정렬 로직 실행
            self.sortMarketTickers(by: sortOption)
        }
    }
    
    // MARK: 코인 검색어
    let searchQuerySubject: PublishSubject<String> = PublishSubject<String>()
    
    
    
    // MARK: - Place for Output
    // MARK: 업비트에서 거래 가능한 종목리스트 주제
    let marketTickerSubject: PublishSubject<[MarketTicker]> = PublishSubject<[MarketTicker]>()
    
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
        
        // MARK: 코인 검색어 구독
        self.searchQuerySubject
            .asObservable()
            .subscribe(onNext: { [weak self] query in
                guard let self = self else { return }
                self.queryMarketTickers(by: query)
            }).disposed(by: disposeBag)
    }
    
    // MARK: 업비트에서 거래 가능한 종목 조회 후, 종목별 현재가 조회
    private func fetchMarketTicker(currency: CurrencyType) {
        // MARK: 1. 거래 가능한 종목 가져오기
        UpbitApiService.request(endpoint: .marketAll(is_details: true)) { [weak self] (result: Result<[MarketInfo], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let markets):
                // MARK: 2. 화폐별 현재가 가져오기
                UpbitApiService.request(endpoint: .tickerAll(quote_currencies: currency.rawValue)) { [weak self] (result: Result<[ApiTicker], Error>) in
                    guard let self = self else { return }
                    switch result {
                    case .success(let tickers):
                        // MARK: 3. 두 데이터를 market을 기준으로 매칭하여 데이터 생성
                        // MARK: tickers 배열을 딕셔너리로 변환 (market을 key로 설정)
                        let tickerDictionay = Dictionary(uniqueKeysWithValues: tickers.map { ($0.market, $0)})
                        
                        // MARK: markets 배열을 순회하면서, 매칭되는 ticker가 있는 경우 MarketTicker 생성
                        let marketTickers: [MarketTicker] = markets.compactMap { market in
                            if let ticker = tickerDictionay[market.market] {
                                return MarketTicker(marketInfo: market, ticker: ticker)
                            }
                            return nil
                        }
                        // MARK: 내부에 저장하고, 정렬 및 UI에 방출
                        self.marketTickers = marketTickers
                        self.filteredTickers = marketTickers
                        self.sortMarketTickers(by: self.sortOption)
                        
                        // MARK: 웹소켓 구독 요청, 현재 매칭된 마켓 코드 리스트 전달
                        let marketCodes = tickers.map(\.market)
                        self.webSocketService.subscribeTo(types: [.ticker], symbol: marketCodes)
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        self.messageSubject.onNext(error.localizedDescription)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
                self.messageSubject.onNext(error.localizedDescription)
            }
        }
    }
    
    // MARK: 코인 순서 정렬
    private func sortMarketTickers(by option: SortOption) {
        switch option {
        case .volume24Descending:
            filteredTickers.sort { $0.ticker.acc_trade_price_24h > $1.ticker.acc_trade_price_24h }
        case .volume24Ascending:
            filteredTickers.sort { $0.ticker.acc_trade_price_24h < $1.ticker.acc_trade_price_24h }
        case .priceDescending:
            filteredTickers.sort { $0.ticker.trade_price > $1.ticker.trade_price }
        case .priceAscending:
            filteredTickers.sort { $0.ticker.trade_price < $1.ticker.trade_price }
        case .nameAscending:
            filteredTickers.sort { $0.marketInfo.koreanName < $1.marketInfo.koreanName }
        case .nameDescending:
            filteredTickers.sort { $0.marketInfo.koreanName > $1.marketInfo.koreanName }
        }
        self.marketTickerSubject.onNext(self.filteredTickers)
    }
    
    // MARK: 코인 검색 필터링
    private func queryMarketTickers(by query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)
            
        if trimmedQuery.isEmpty {
            // MARK: 검색어가 없으면 현재 정렬을 기준으로 전체 데이터 방출
            self.filteredTickers = self.marketTickers
            self.sortMarketTickers(by: self.sortOption)
        } else {
            // MARK: 검색어가 포함된 방목이 있다면 필터링된 데이터 방출
            let lowerQuery = trimmedQuery.lowercased()
            self.filteredTickers = marketTickers.filter {
                $0.marketInfo.koreanName.lowercased().contains(lowerQuery) ||
                $0.marketInfo.englishName.lowercased().contains(lowerQuery)
            }
            self.marketTickerSubject.onNext(self.filteredTickers)
            // TODO: 한글 초성 검색 or 검색과정중 필터링 진행(ex 비트코인 -> 빝, 비틐, 비트콩, 비트코이 ...)
        }
    }
    
    // MARK: WebSocketDelegate에서 발생하는 WebSocket Event 처리
    private func didReceiveEvent(event: WebSocketEvent) {
        
        let className = String(describing: self)
        
        switch event {
            
            // MARK: 소켓이 연결됨
        case .connected(let headers):
            print("\(className): websocket is connected: \(headers)")
            // MARK: 거래가능한 종목 조회 + 해당 종목의 현재가 조회
            self.fetchMarketTicker(currency: .krw)
            
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
        if let ticker: SocketTicker = SocketTicker.parseData(data),
           let index = self.filteredTickers.firstIndex(where: { $0.marketInfo.market == ticker.code }) {
            
            // MARK: 업데이트된 Ticker 삽입
            self.filteredTickers[index].ticker = ticker
            
            // MARK: 업데이트된 MarketTicker 방출(socketTicker로 ticker 값만 변경될 때에는 로드시 최초의 정렬값 사용함)
            self.marketTickerSubject.onNext(self.filteredTickers)
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
