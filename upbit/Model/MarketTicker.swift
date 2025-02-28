//
//  MarketTicker.swift
//  upbit
//
//  Created by 홍정연 on 2/25/25.
//

import Foundation

// MARK: MarketInfo와 Ticker가 결합한 모델
struct MarketTicker: Hashable{
    let marketInfo: MarketInfo
    let ticker: ApiTicker
}
