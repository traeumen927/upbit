//
//  ChangeType.swift
//  upbit
//
//  Created by 홍정연 on 2/17/25.
//

import UIKit

enum ChangeType: String, Codable {
    case even = "EVEN"
    case rise = "RISE"
    case fall = "FALL"
    
    var color: UIColor {
        switch self {
        case .even:
            return ThemeColor.evenBackground
        case .rise:
            return ThemeColor.risePrimary
        case .fall:
            return ThemeColor.fallPrimary
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        switch rawValue {
        case "EVEN":
            self = .even
        case "RISE":
            self = .rise
        case "FALL":
            self = .fall
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid change type: \(rawValue)")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
