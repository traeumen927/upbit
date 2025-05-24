//
//  Demical.swift
//  upbit
//
//  Created by 홍정연 on 5/23/25.
//

import Foundation

extension Decimal {
    
    /// 소수점 8자리까지 버림 처리 (업비트 스타일)
    func truncatedTo8Digits() -> Decimal {
        let behavior = NSDecimalNumberHandler(
            roundingMode: .down, // towardZero
            scale: 8,
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false
        )
        let number = NSDecimalNumber(decimal: self)
        return number.rounding(accordingToBehavior: behavior).decimalValue
    }
    
    // 원하는 자리까지 절삭
    func formattedStringWithTruncation(places: Int) -> String {
        let handler = NSDecimalNumberHandler(
            roundingMode: .down, // ❗️반올림이 아닌 절삭
            scale: Int16(places),
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false
        )
        let truncated = NSDecimalNumber(decimal: self).rounding(accordingToBehavior: handler)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = places
        return formatter.string(from: truncated) ?? truncated.stringValue
    }
    
    // 반올림
    func rounded(scale: Int, mode: NSDecimalNumber.RoundingMode = .plain) -> Decimal {
        let handler = NSDecimalNumberHandler(
            roundingMode: mode,
            scale: Int16(scale),
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false
        )
        return NSDecimalNumber(decimal: self).rounding(accordingToBehavior: handler).decimalValue
    }
}
