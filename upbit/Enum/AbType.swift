//
//  AbType.swift
//  upbit
//
//  Created by 홍정연 on 2/25/25.
//

import Foundation

enum AbType: String, Codable {
    ///매수
    case ask = "ASK"
    ///매도
    case bid = "BID"

    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        switch rawValue {
        case "ASK":
            self = .ask
        case "BID":
            self = .bid
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid change type: \(rawValue)")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
