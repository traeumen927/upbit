//
//  MyOrder.swift
//  upbit
//
//  Created by 홍정연 on 5/25/25.
//

import Foundation

/// 주문 및 체결 내역(*WebSocket 용)
struct MyOrder: Decodable, Hashable {
    /// 타입 (myOrder : 내 주문)
    let type: String
    
    /// 마켓 코드 (ex. KRW-BTC)
    let code: String
    
    /// 주문 고유 아이디
    let uuid: String
    
    /// 매수/매도 구분
    let ask_bid: String
    
    /// 주문 타입 (*limit: 지정가 주문, price: 시장가 매수 주문, market: 시장가 매도 주문, best: 최유리 지정가 주문)
    let order_type: String
    
    /// 주문 상태 (*wait: 체결 대기, watch: 예약 주문 대기, trade: 체결 발생, done: 전체 체결 완료, cancel: 주문 취소)
    let state: String
    
    /// 체결의 고유 아이디 (JSON이 null로 올 수 있으므로 Optional)
    let trade_uuid: String?
    
    /// 주문 가격, 체결 가격 (state: trade 일 때)
    let price: Double
    
    /// 평균 체결 가격
    let avg_price: Double
    
    /// 주문량, 체결량 (state: trade 일 때)
    let volume: Double
    
    /// 체결 후 남은 주문 양
    let remaining_volume: Double
    
    /// 체결된 양
    let executed_volume: Double
    
    /// 해당 주문에 걸린 체결 수
    let trades_count: Int
    
    /// 수수료로 예약된 비용
    let reserved_fee: Double
    
    /// 남은 수수료
    let remaining_fee: Double
    
    /// 사용된 수수료
    let paid_fee: Double
    
    /// 거래에 사용중인 비용
    let locked: Double
    
    /// 체결된 금액
    let executed_funds: Double
    
    /// IOC, FOK 설정 (*ioc, fok) (JSON이 null로 올 수 있으므로 Optional)
    let time_in_force: String?
    
    /// 체결 시 발생한 수수료 (trade 타입이 아닐 경우 null 값) (Optional)
    let trade_fee: Double?
    
    /// 체결이 발생한 주문의 maker / taker 여부 (trade 타입이 아닐 경우 null 값) (Optional)
    let is_maker: Bool?
    
    /// 조회용 사용자 지정값 ( *identifier 필드는 2024-10-18 이후에 생성된 주문에 대해서만 제공합니다.) (Optional)
    let identifier: String?
    
    /// 체결 타임스탬프 (millisecond, JSON이 null로 올 수 있으므로 Optional)
    let trade_timestamp: Int64?
    
    /// 주문 타임스탬프 (millisecond)
    let order_timestamp: Int64
    
    /// 타임스탬프 (millisecond)
    let timestamp: Int64
    
    /// 스트림 타입 (REALTIME : 실시간)
    let stream_type: String
}
