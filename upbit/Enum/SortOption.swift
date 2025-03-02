//
//  SortOption.swift
//  upbit
//
//  Created by 홍정연 on 3/2/25.
//

import Foundation

// MARK: 거래소 정렬 옵션
enum SortOption: String, CaseIterable {
    ///24시간 누적 거래량(금액) 많은 순
    case volume24Descending = "거래량 많은 순"
    
    ///24시간 누적 거래량(금액) 적은 순
    case volume24Ascending = "거래량 적은 순"
    
    /// 현재가 높은 순
    case priceDescending = "현재가 높은 순"
    
    /// 현재가 낮은 순
    case priceAscending = "현재가 낮은 순"
    
    /// 이름 내림차순
    case nameDescending = "코인명 내림차순"
    
    /// 이름 오름차순
    case nameAscending = "코인명 오름차순"
}
