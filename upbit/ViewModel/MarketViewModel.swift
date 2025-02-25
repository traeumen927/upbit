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
    let marketSubject: PublishSubject<[Market]> = PublishSubject<[Market]>()
    
    init() {
        self.fetchMarketAll()
    }
    
    // MARK: 업비트에서 거래 가능한 종목 조회
    private func fetchMarketAll() {
        UpbitApiService.request(endpoint: .marketAll(is_details: true)) { [weak self] (result: Result<[Market], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let markets):
                self.marketSubject.onNext(markets)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
