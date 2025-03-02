//
//  MarketTicker.swift
//  upbit
//
//  Created by 홍정연 on 2/25/25.
//

import Foundation

// MARK: MarketInfo와 Ticker가 결합한 모델
struct MarketTicker: Hashable{
    
    /// 코인정보
    let marketInfo: MarketInfo
    
    // MARK: Swift 5.7 이상에서는 프로토콜을 존재형 타입으로 사용할 때 any Protocol과 같이 명시해야함
    /// 현재가 정보 (TickerProtocol를 준수하는 ApiTicker or SocketTicker)
    var ticker: any TickerProtocol
    
    // MARK: 자동 합성이 불가능 하므로, 존재형 타입을 저장 프로퍼티로 사용할 경우에는 직접 Equtable/Hashable 구현을 제공해야함
    static func == (lhs: MarketTicker, rhs: MarketTicker) -> Bool {
            // marketInfo는 구체 타입이므로 자동 비교 가능
            guard lhs.marketInfo == rhs.marketInfo else { return false }
            // ticker의 경우, 두 ticker의 타입이 같은지 먼저 확인하고 hashValue를 비교하는 방식
            guard type(of: lhs.ticker) == type(of: rhs.ticker) else { return false }
            return lhs.ticker.hashValue == rhs.ticker.hashValue
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(marketInfo)
            hasher.combine(ticker.hashValue)
        }
}

// MARK: Api Ticker와 SocketTicker의 공통된 변수
protocol TickerProtocol: Hashable {
    var trade_date:String { get }
    var trade_time:String { get }
    var trade_timestamp:Double { get }
    var opening_price:Double { get }
    var high_price:Double { get }
    var low_price:Double { get }
    var trade_price:Double { get }
    var prev_closing_price:Double { get }
    var change:ChangeType { get }
    var change_price:Double { get }
    var change_rate:Double { get }
    var signed_change_price:Double { get }
    var signed_change_rate:Double { get }
    var trade_volume:Double { get }
    var acc_trade_price:Double { get }
    var acc_trade_price_24h:Double { get }
    var acc_trade_volume:Double { get }
    var acc_trade_volume_24h:Double { get }
    var highest_52_week_price:Double { get }
    var highest_52_week_date:String { get }
    var lowest_52_week_price:Double { get }
    var lowest_52_week_date:String { get }
}
