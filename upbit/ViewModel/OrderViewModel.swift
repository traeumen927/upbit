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
    
    init(tickerObservable: Observable<SocketTicker>, orderbookObservable: Observable<Orderbook>) {
        self.tickerObservable = tickerObservable
        self.orderbookObservable = orderbookObservable
    }
}
