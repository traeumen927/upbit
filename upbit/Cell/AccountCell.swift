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
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = ThemeColor.label1
        return label
    }()
    
    // MARK: 코인 심볼 라벨
    private lazy var codeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = ThemeColor.label2
        return label
    }()
    
    // MARK: 코인 수량 라벨
    private lazy var balanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = ThemeColor.label2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    // MARK: 코인 구매평균가 라벨
    private lazy var averageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = ThemeColor.label2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    // MARK: 코인 총평가액 라벨
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = ThemeColor.label1
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    // MARK: 코인 수익/손실액 라벨
    private lazy var changeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = ThemeColor.evenPrimary
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
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
        
        self.initializedLayout()
    }
    
    // MARK: 데이터 초기화
    private func initializedLayout() {
        [nameLabel, codeLabel, balanceLabel, averageLabel, amountLabel, changeLabel].forEach { $0.text = " " }
        
        changeLabel.textColor = ChangeType.even.color
    }
    
    // MARK: 셀 레이아웃 설정
    private func layout() {
        
        self.selectionStyle = .none
        
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
        
        // MARK: 데이터 초기설정
        self.initializedLayout()
    }
    
    // MARK: data binding in cell
    func configure(with accountTicker: AccountTicker) {
        
        // MARK: 보유 수량(수량 + 주문중 묶인 수량)
        let count = accountTicker.account.balance + accountTicker.account.locked
        
        // MARK: 투자된 금액
        let investedAmount: Double = Double(accountTicker.account.avg_buy_price) * Double(count)
        
        // MARK: 현재의 가치
        let currentAmount: Double = Double(accountTicker.ticker.trade_price) * Double(count)
        
        // MARK: 코인 수익/손실액
        let changeAmount = currentAmount - investedAmount
        
        // MARK: 코인 수익/손실률
        let changeRate = investedAmount != 0 ? (changeAmount / investedAmount * 100) : 0.0

        // MARK: 양수면 '+' 부호 지정
        let sign = changeAmount >= 0 ? "+" : ""
        
        // MARK: 코인 이름
        self.nameLabel.text = accountTicker.marketInfo.koreanName
        
        // MARK: 코인 심볼
        self.codeLabel.text = accountTicker.account.currency
        
        // MARK: 코인 수량
        self.balanceLabel.text = "보유수량 \(count.formattedStringWithCommaAndDecimal(places: 6, removeZero: true)) \(accountTicker.account.currency)"
        
        // MARK: 코인 평균 구매가
        self.averageLabel.text = "매수평균 \(accountTicker.account.avg_buy_price.formattedStringWithCommaAndDecimal(places: 2, removeZero: false)) \(accountTicker.account.unit_currency)"
        
        // MARK: 코인 총 평가액
        self.amountLabel.text = "\(currentAmount.formattedStringWithCommaAndDecimal(places: 0)) \(accountTicker.account.unit_currency)"
        
        // MARK: 코인 수익/손실액
        self.changeLabel.text = "\(sign)\(changeRate.formattedStringWithCommaAndDecimal(places: 2, removeZero: false))% (\(changeAmount.formattedStringWithCommaAndDecimal(places: 0)))"
        
        // MARK: 코인 수익/손실 라벨 색상 설정
        self.changeLabel.textColor = changeAmount.changeType.color
    }
}
