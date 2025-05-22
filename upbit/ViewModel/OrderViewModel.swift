//
//  OrderViewModel.swift
//  upbit
//
//  Created by 홍정연 on 4/10/25.
//

import RxSwift

class OrderViewModel {
    
    // MARK: disposeBag
    private let disposeBag = DisposeBag()
    
    // MARK: 현재가 Observable
    private(set) var tickerObservable: Observable<SocketTicker>
    
    // MARK: 호가 Observable
    private(set) var orderbookObservable: Observable<Orderbook>
    
    // MARK: - Place for Input
    // MARK: 선택된 마켓
    private let market: String
    
    // MARK: - Place for Output
    // MARK: 주문가능정보 주제
    let chanceSubject: PublishSubject<Chance> = PublishSubject<Chance>()
    
    // MARK: 메세지 주제
    let messageSubject: PublishSubject<String> = PublishSubject<String>()
    
    init(market: String, tickerObservable: Observable<SocketTicker>, orderbookObservable: Observable<Orderbook>) {
        self.market = market
        self.tickerObservable = tickerObservable
        self.orderbookObservable = orderbookObservable
        
        self.fetchChance(market: market)
    }
    
    // MARK: 주문 가능 정보 조회
    private func fetchChance(market: String) {
        
        UpbitApiService.request(endpoint: .ordersChance(market: market)) { [weak self] (result: Result<Chance, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let chance):
                self.chanceSubject.onNext(chance)
            case .failure(let error):
                self.messageSubject.onNext(error.localizedDescription)
                print("error: \(error.localizedDescription)")
            }
        }
    }
}
