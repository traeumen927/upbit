//
//  Chance.swift
//  upbit
//
//  Created by 홍정연 on 5/16/25.
//

import Foundation

// MARK: 주문 가능 정보
struct Chance: Decodable {
    /// 매수 수수료 비율
    let bidFee: Double
    /// 매도 수수료 비율
    let askFee: Double
    /// 메이커 매수 수수료 비율
    let makerBidFee: Double
    /// 메이커 매도 수수료 비율
    let makerAskFee: Double
    /// 마켓에 대한 정보
    let market: ChanceMarket
    /// 매수 시 사용하는 화폐의 계좌 상태
    let bidAccount: Account
    /// 매도 시 사용하는 화폐의 계좌 상태
    let askAccount: Account

    enum CodingKeys: String, CodingKey {
        case bidFee = "bid_fee"
        case askFee = "ask_fee"
        case makerBidFee = "maker_bid_fee"
        case makerAskFee = "maker_ask_fee"
        case market
        case bidAccount = "bid_account"
        case askAccount = "ask_account"
    }
}

// MARK: 마켓 정보
struct ChanceMarket: Decodable {
    /// 마켓의 유일 키
    let id: String
    /// 마켓 이름
    let name: String
    /// 지원 주문 종류
    let orderSides: [AbType]
    /// 매수 주문 지원 방식
    let bidTypes: [String]
    /// 매도 주문 지원 방식
    let askTypes: [String]
    /// 매수 시 제약사항
    let bid: CurrencyInfo
    /// 매도 시 제약사항
    let ask: CurrencyInfo
    /// 최대 매도/매수 금액
    let maxTotal: Decimal
    /// 마켓 운영 상태
    let state: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case orderSides = "order_sides"
        case bidTypes = "bid_types"
        case askTypes = "ask_types"
        case bid, ask
        case maxTotal = "max_total"
        case state
    }
}

// MARK: 주문 화폐 정보
struct CurrencyInfo: Decodable {
    /// 화폐를 의미하는 영문 대문자 코드
    let currency: String
    /// 최소 매도/매수 금액
    let minTotal: Decimal

    enum CodingKeys: String, CodingKey {
        case currency
        case minTotal = "min_total"
    }
}
