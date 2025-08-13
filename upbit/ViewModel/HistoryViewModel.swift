//
//  HistoryViewModel.swift
//  upbit
//
//  Created by 홍정연 on 5/25/25.
//

import Foundation
import RxSwift
import RxCocoa

class HistoryViewModel {

    // MARK: 주문 목록
    private var pendingOrders: [String: MyOrder] = [:]
    private var filledOrders: [MyOrder] = []

    // MARK: Output
    let pendingOrdersRelay = BehaviorRelay<[MyOrder]>(value: [])
    let filledOrdersRelay = BehaviorRelay<[MyOrder]>(value: [])

    // MARK: Input
    let cancelSubject = PublishSubject<String>()

    private let disposeBag = DisposeBag()

    init(myOrderObservable: Observable<MyOrder>) {
        myOrderObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] order in
                self?.handle(order)
            })
            .disposed(by: disposeBag)

        cancelSubject
            .flatMapLatest { uuid -> Observable<Void> in
                return Observable.create { observer in
                    UpbitApiService.request(endpoint: .cancelOrder(uuid: uuid), method: .delete) { (result: Result<Order, Error>) in
                        observer.onNext(())
                        observer.onCompleted()
                    }
                    return Disposables.create()
                }
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    private func handle(_ order: MyOrder) {
        switch order.state {
        case "done":
            pendingOrders.removeValue(forKey: order.uuid)
            filledOrders.insert(order, at: 0)
        case "cancel":
            pendingOrders.removeValue(forKey: order.uuid)
        default:
            pendingOrders[order.uuid] = order
        }

        pendingOrdersRelay.accept(Array(pendingOrders.values))
        filledOrdersRelay.accept(filledOrders)
    }
}

