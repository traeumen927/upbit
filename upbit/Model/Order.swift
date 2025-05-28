//
//  Order.swift
//  upbit
//
//  Created by 홍정연 on 5/25/25.
//

import Foundation

/// 주문내역(*API 용)
struct Order: Decodable {
    /// 주문의 고유 아이디
    let uuid: String
    
    /// 주문 종류
    let side: String
    
    /// 주문 방식
    let ord_type: String
    
    /// 주문 당시 화폐 가격
    let price: String
    
    /// 주문 상태
    let state: String
    
    /// 마켓의 유일키
    let market: String
    
    /// 주문 생성 시간
    let created_at: String
    
    /// 사용자가 입력한 주문 양
    let volume: String
    
    /// 체결 후 남은 주문 양
    let remaining_volume: String
    
    /// 수수료로 예약된 비용
    let reserved_fee: String
    
    /// 남은 수수료
    let remaining_fee: String
    
    /// 사용된 수수료
    let paid_fee: String
    
    /// 거래에 사용중인 비용
    let locked: String
    
    /// 체결된 양
    let executed_volume: String
    
    /// 해당 주문에 걸린 체결 수
    let trades_count: Int
    
    /// IOC, FOK 설정
    let time_in_force: String?
    
    /// 조회용 사용자 지정값(*identifier 필드는 2024-10-18 이후에 생성된 주문에 대해서만 제공합니다.)
    let identifier: String?
}
