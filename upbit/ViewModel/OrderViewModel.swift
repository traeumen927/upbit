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
        
        UpbitApiService.request(endpoint: .ordersChance(market: market), method: .get) { [weak self] (result: Result<Chance, Error>) in
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
    
    // MARK: 주문 진행
    func postOrders(market: String, side: String, volume: String, price: String, ordType: String) {
        
        UpbitApiService.request(endpoint: .orders(market: market, side: side, volume: volume, price: price, ordType: ordType), method: .post) { (result: Result<Order, Error>) in
            switch result {
            case .success(let order):
                print("✅ 주문 성공: \(order)")
                // 예: self.showToast("주문이 완료되었습니다.")
                self.messageSubject.onNext("주문이 완료되었습니다.")
            case .failure(let error):
                print("❌ 주문 실패: \(error.localizedDescription)")
                self.messageSubject.onNext("주문 실패: \(error.localizedDescription)")
            }
        }
    }
}
