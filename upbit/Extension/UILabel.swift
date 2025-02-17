//
//  UILabel.swift
//  upbit
//
//  Created by 홍정연 on 2/17/25.
//

import UIKit

extension UILabel {
    /// UILabel을 생성하는 팩토리 메서드
    ///
    /// - Parameters:
    ///   - text: 라벨에 표시할 텍스트 (기본값: nil)
    ///   - textColor: 텍스트 색상 (기본값: .black)
    ///   - font: 폰트 (기본값: 시스템 폰트, 크기 14)
    ///   - textAlignment: 텍스트 정렬 (기본값: .left)
    ///   - numberOfLines: 표시할 줄 수 (기본값: 1)
    ///   - backgroundColor: 배경색 (기본값: .clear)
    /// - Returns: 구성된 UILabel 인스턴스
    static func createLabel(text: String? = nil,
                            textColor: UIColor = .label,
                            font: UIFont = .systemFont(ofSize: 14, weight: .regular),
                            textAlignment: NSTextAlignment = .left,
                            numberOfLines: Int = 1,
                            backgroundColor: UIColor = .clear) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = textColor
        label.font = font
        label.textAlignment = textAlignment
        label.numberOfLines = numberOfLines
        label.backgroundColor = backgroundColor
        return label
    }
}
