//
//  AccountCell.swift
//  upbit
//
//  Created by 홍정연 on 3/31/25.
//

import UIKit
import SnapKit

// MARK: 보유자산 테이블뷰 셀
class AccountCell: UITableViewCell {
    static let cellId = "AccountCell"
    
    // MARK: 코인명 라벨
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = ThemeColor.label1
        return label
    }()
    
    // MARK: 코인 심볼 라벨
    private lazy var codeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = ThemeColor.label1
        return label
    }()
    
    // MARK: 코인 수량 라벨
    private lazy var balanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = ThemeColor.label1
        return label
    }()
    
    // MARK: 코인 구매평균가 라벨
    private lazy var averageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = ThemeColor.label1
        return label
    }()
    
    // MARK: 코인 총평가액 라벨
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = ThemeColor.label1
        label.textAlignment = .right
        return label
    }()
    
    // MARK: 코인 수익/손실액 라벨
    private lazy var changeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = ThemeColor.evenPrimary
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: 셀 재사용전 데이터 초기화
    override func prepareForReuse() {
        super.prepareForReuse()
        
        [nameLabel, codeLabel, balanceLabel, averageLabel, amountLabel, changeLabel].forEach { $0.text = "-" }
    }
    
    // MARK: 셀 레이아웃 설정
    private func layout() {
        [nameLabel, codeLabel, balanceLabel, averageLabel, amountLabel, changeLabel].forEach(self.contentView.addSubview(_:))
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(self.contentView.snp.centerX).offset(-4)
        }
        
        codeLabel.snp.makeConstraints { make in
            make.top.equalTo(self.nameLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(self.contentView.snp.centerX).offset(-4)
        }
        
        balanceLabel.snp.makeConstraints { make in
            make.top.equalTo(self.codeLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(self.contentView.snp.centerX).offset(-4)
        }
        
        averageLabel.snp.makeConstraints { make in
            make.top.equalTo(self.balanceLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(self.contentView.snp.centerX).offset(-4)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        amountLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.contentView.snp.centerX).offset(4)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(self.contentView.snp.centerY).offset(-2)
        }
        
        changeLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.contentView.snp.centerX).offset(4)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(self.contentView.snp.centerY).offset(2)
        }
    }
}
