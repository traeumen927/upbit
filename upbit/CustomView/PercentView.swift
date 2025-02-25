//
//  PercentView.swift
//  upbit
//
//  Created by 홍정연 on 2/17/25.
//

import UIKit
import SnapKit

class PercentView: UIView {
    private let percentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = ThemeColor.lable3
        label.textAlignment = .right
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layout()
    }
    
    private func layout() {
        self.layer.cornerRadius = 6
        addSubview(percentLabel)
        percentLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.trailing.equalToSuperview().offset(-4)
            make.bottom.equalToSuperview().offset(-4)
            make.leading.greaterThanOrEqualToSuperview().offset(4)
        }
    }
    
    func setPercentage(_ percentage: Double) {
        percentLabel.text = "\(percentage.roundedString(places: 2))%"
        
        if percentage > 0 {
            // MARK: 빨간색 배경
            backgroundColor = ThemeColor.risePrimary
        } else if percentage < 0 {
            // MARK: 파란색 배경
            backgroundColor = ThemeColor.fallPrimary
        } else {
            // MARK: 회색 배경
            backgroundColor = ThemeColor.evenBackground
        }
    }
}

