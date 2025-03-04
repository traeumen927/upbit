//
//  UIView.swift
//  upbit
//
//  Created by 홍정연 on 3/4/25.
//

import UIKit

enum ShadowDirection {
    case top
    case bottom
    case left
    case right
}

extension UIView {
    /// 지정한 방향 배열에 따라 여러 개의 그림자 효과를 추가합니다.
    /// - Parameters:
    ///   - directions: 그림자를 적용할 방향 배열 (예: [.top, .bottom])
    ///   - shadowColor: 그림자 색상 (기본값: .black)
    ///   - shadowOpacity: 그림자 불투명도 (기본값: 0.3)
    ///   - shadowRadius: 그림자 반경 (기본값: 4.0)
    func addShadows(directions: [ShadowDirection],
                    shadowColor: UIColor = .black,
                    shadowOpacity: Float = 0.3,
                    shadowRadius: CGFloat = 4.0) {
        // 기존에 추가된 사용자 그림자 레이어 제거 (이름을 이용)
        self.layer.sublayers?.removeAll(where: { $0.name == "customShadowLayer" })
        
        // 각 방향마다 별도의 shadow layer 추가
        for direction in directions {
            let shadowLayer = CALayer()
            shadowLayer.name = "customShadowLayer"
            shadowLayer.frame = self.bounds
            // 배경색을 동일하게 설정하여 그림자가 자연스럽게 보이도록 합니다.
            shadowLayer.backgroundColor = self.backgroundColor?.cgColor ?? UIColor.white.cgColor
            shadowLayer.shadowColor = shadowColor.cgColor
            shadowLayer.shadowOpacity = shadowOpacity
            shadowLayer.shadowRadius = shadowRadius
            shadowLayer.masksToBounds = false
            
            switch direction {
            case .top:
                shadowLayer.shadowOffset = CGSize(width: 0, height: -2)
            case .bottom:
                shadowLayer.shadowOffset = CGSize(width: 0, height: 2)
            case .left:
                shadowLayer.shadowOffset = CGSize(width: -2, height: 0)
            case .right:
                shadowLayer.shadowOffset = CGSize(width: 2, height: 0)
            }
            
            // 성능 개선을 위해 shadowPath를 지정할 수 있습니다.
            shadowLayer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
            
            // shadowLayer를 view의 layer 맨 아래에 추가합니다.
            self.layer.insertSublayer(shadowLayer, at: 0)
        }
    }
}
