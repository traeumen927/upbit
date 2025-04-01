//
//  AccountTicker.swift
//  upbit
//
//  Created by 홍정연 on 3/29/25.
//

import Foundation

// MARK: MarketInfo, Account와 Ticker가 결합한 모델
struct AccountTicker: Hashable{
    
    /// 코인정보
    let marketInfo: MarketInfo
    
    /// 자산정보
    let account: Account
    
    // MARK: Swift 5.7 이상에서는 프로토콜을 존재형 타입으로 사용할 때 any Protocol과 같이 명시해야함
    /// 현재가 정보 (TickerProtocol를 준수하는 ApiTicker or SocketTicker)
    var ticker: any TickerProtocol
    
    // MARK: 자동 합성이 불가능 하므로, 존재형 타입을 저장 프로퍼티로 사용할 경우에는 직접 Equtable/Hashable 구현을 제공해야함
    static func == (lhs: AccountTicker, rhs: AccountTicker) -> Bool {
        // marketInfo는 구체 타입이므로 자동 비교 가능
        guard lhs.marketInfo == rhs.marketInfo else { return false }
        // account는 구체 타입이므로 자동 비교 가능
        guard lhs.account == rhs.account else { return false }
        // ticker의 경우, 두 ticker의 타입이 같은지 먼저 확인하고 hashValue를 비교하는 방식
        guard type(of: lhs.ticker) == type(of: rhs.ticker) else { return false }
        return lhs.ticker.hashValue == rhs.ticker.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(account)
        hasher.combine(ticker.hashValue)
    }
}
