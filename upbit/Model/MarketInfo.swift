//
//  MarketInfo.swift
//  upbit
//
//  Created by 홍정연 on 2/25/25.
//

import Foundation

struct MarketInfo: Decodable, Hashable {
    
    ///업비트에서 제공중인 시장 정보
    let market: String
    ///거래 대상 디지털 자산 한글명
    let koreanName: String
    ///거래 대상 디지털 자산 영문명
    let englishName: String
    ///업비트 시장 경보
    let marketEvent: MarketEvent
    
    enum CodingKeys: String, CodingKey {
        case market
        case koreanName = "korean_name"
        case englishName = "english_name"
        case marketEvent = "market_event"
    }
}

// MARK: 업비트 시장 경보
struct MarketEvent: Decodable, Hashable {
    /// 업비트 유의종목 지정 여부
    let warning: Bool
    /// 업비트 주의종목 지정 여부
    let caution: Caution
    
    enum CodingKeys: String, CodingKey {
        case warning
        case caution
    }
}

// MARK: 업비트 주의 종목 상세
struct Caution: Decodable, Hashable {
    let priceFluctuations: Bool
    let tradingVolumeSoaring: Bool
    let depositAmountSoaring: Bool
    let globalPriceDifferences: Bool
    let concentrationOfSmallAccounts: Bool
    
    enum CodingKeys: String, CodingKey {
        case priceFluctuations = "PRICE_FLUCTUATIONS"
        case tradingVolumeSoaring = "TRADING_VOLUME_SOARING"
        case depositAmountSoaring = "DEPOSIT_AMOUNT_SOARING"
        case globalPriceDifferences = "GLOBAL_PRICE_DIFFERENCES"
        case concentrationOfSmallAccounts = "CONCENTRATION_OF_SMALL_ACCOUNTS"
    }
}
