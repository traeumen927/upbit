//
//  SocketRequestType.swift
//  upbit
//
//  Created by 홍정연 on 2/28/25.
//

import Foundation

// MARK: 웹소켓 통신에서 사용하는 구독 타입
enum SocketRequestType: String {
    ///현재가
    case ticker
    
    ///호가
    case orderbook
    
    ///내 주문 및 체결
    case myOrder
    
    ///체결
    case trade
    
    
    /// 인증의 필요 여부
    var requiresAuth: Bool {
        switch self {
        case .myOrder:
            return true
        default:
            return false
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        switch rawValue {
        case "ticker":
            self = .ticker
        case "orderbook":
            self = .orderbook
        case "myOrder":
            self = .myOrder
        case "trade":
            self = .trade
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid change type: \(rawValue)")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
