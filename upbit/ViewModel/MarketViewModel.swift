//
//  MarketViewModel.swift
//  upbit
//
//  Created by 홍정연 on 2/17/25.
//

import Foundation
import RxSwift
import RxCocoa

class MarketViewModel {
    
    // MARK: 업비트에서 거래 가능한 종목리스트 주제
    let marketTickerSubject: PublishSubject<[MarketTicker]> = PublishSubject<[MarketTicker]>()
    
    // MARK: 메세지 주제
    let messageSubject: PublishSubject<String> = PublishSubject<String>()
    
    init() {
        // MARK: 거래가능한 종목 조회 + 해당 종목의 현재가 조회
        self.fetchMarketTicker(currencies: [.krw])
    }
    
    // MARK: 업비트에서 거래 가능한 종목 조회 후, 종목별 현재가 조회
    private func fetchMarketTicker(currencies: [CurrencyType]) {
        // MARK: 1. 거래 가능한 종목 가져오기
        UpbitApiService.request(endpoint: .marketAll(is_details: true)) { [weak self] (result: Result<[MarketInfo], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let markets):
                // MARK: 요청 화폐 ex) "KRW, BTC, USDT"
                let currenciesString = currencies.map { $0.rawValue }.joined(separator: ", ")
                
                // MARK: 2. 화폐별 현재가 가져오기
                UpbitApiService.request(endpoint: .tickerAll(quote_currencies: currenciesString)) { [weak self] (result: Result<[ApiTicker], Error>) in
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
                        self.marketTickerSubject.onNext(marketTickers)
                        
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
}
