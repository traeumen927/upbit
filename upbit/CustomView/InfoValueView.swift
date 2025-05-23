//
//  InfoValueView.swift
//  upbit
//
//  Created by 홍정연 on 5/21/25.
//

import UIKit
import SnapKit

class InfoValueView: UIView {
    
    // MARK: 제목 라벨
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeColor.label1
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    // MARK: 값 라벨
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeColor.label1
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.lineBreakMode = .byTruncatingTail
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    // MARK: 단위 라벨
    private let unitLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeColor.label2
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        // MARK: value보다 우선순위를 높게하여 unit이 truncate 되지 않도록 설정
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    // MARK: - 공개 프로퍼티
    
    /// 타이틀 텍스트
    var title: String = "" {
        didSet { titleLabel.text = title }
    }
    
    /// 값 텍스트
    var value: String {
        get { valueLabel.text ?? "" }
        set { valueLabel.text = newValue }
    }
    
    /// 유닛 텍스트
    var unitText: String? {
        didSet {
            unitLabel.text = unitText
            updateLayoutBasedOnUnit()
        }
    }
    
    /// 폰트 커스터마이징
    var titleFont: UIFont = UIFont.systemFont(ofSize: 12, weight: .bold) {
        didSet { titleLabel.font = titleFont }
    }
    
    var valueFont: UIFont = .systemFont(ofSize: 13, weight: .medium) {
        didSet { valueLabel.font = valueFont }
    }
    
    var unitFont: UIFont = .systemFont(ofSize: 13, weight: .medium) {
        didSet { unitLabel.font = unitFont }
    }
    
    // MARK: - 초기화
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layout()
    }
    
    // MARK: - 뷰 구성
    private func layout() {
        
        [self.titleLabel, self.valueLabel, self.unitLabel].forEach(self.addSubview(_:))
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview().offset(2)
            make.bottom.lessThanOrEqualToSuperview().offset(-2)
        }
        
        updateLayoutBasedOnUnit()
    }
    
    // MARK: Unit의 존재 유무에 따라 Layout 재설정
    private func updateLayoutBasedOnUnit() {
        valueLabel.snp.removeConstraints()
        unitLabel.snp.removeConstraints()
        
        if let unit = unitText, !unit.isEmpty {
            unitLabel.isHidden = false
            
            unitLabel.snp.makeConstraints { make in
                make.trailing.equalToSuperview()
                make.centerY.equalToSuperview()
            }
            
            valueLabel.snp.makeConstraints { make in
                make.trailing.equalTo(unitLabel.snp.leading).offset(-4)
                make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(8)
                make.centerY.equalToSuperview()
            }
            
        } else {
            unitLabel.isHidden = true
            
            valueLabel.snp.makeConstraints { make in
                make.trailing.equalToSuperview()
                make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(8)
                make.centerY.equalToSuperview()
            }
        }
    }
}
