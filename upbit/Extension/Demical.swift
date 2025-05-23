//
//  Demical.swift
//  upbit
//
//  Created by 홍정연 on 5/23/25.
//

import Foundation

extension Decimal {
    func formattedStringWithCommaAndDecimal(places: Int = 2, removeZero: Bool = false) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = removeZero ? 0 : places
        formatter.maximumFractionDigits = places
        return formatter.string(for: self) ?? "\(self)"
    }
    
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
}
