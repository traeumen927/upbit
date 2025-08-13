//
//  HistoryCell.swift
//  upbit
//
//  Created by 홍정연 on 13/08/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class HistoryCell: UITableViewCell {
    static let cellId = "HistoryCell"

    private let nameLabel = UILabel()
    private let sideLabel = UILabel()
    private let timeLabel = UILabel()
    let cancelButton = UIButton(type: .system)

    private let priceTitleLabel = UILabel()
    private let quantityTitleLabel = UILabel()
    private let remainingTitleLabel = UILabel()

    private let priceValueLabel = UILabel()
    private let quantityValueLabel = UILabel()
    private let remainingValueLabel = UILabel()

    var disposeBag = DisposeBag()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    private func layout() {
        selectionStyle = .none

        [nameLabel, sideLabel, timeLabel, cancelButton].forEach(contentView.addSubview)

        let titleStack = UIStackView(arrangedSubviews: [priceTitleLabel, quantityTitleLabel, remainingTitleLabel])
        let valueStack = UIStackView(arrangedSubviews: [priceValueLabel, quantityValueLabel, remainingValueLabel])
        titleStack.axis = .vertical
        titleStack.spacing = 4
        valueStack.axis = .vertical
        valueStack.spacing = 4

        [titleStack, valueStack].forEach(contentView.addSubview)

        nameLabel.font = .systemFont(ofSize: 14, weight: .bold)

        sideLabel.font = .systemFont(ofSize: 14, weight: .bold)

        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = ThemeColor.label2

        [priceTitleLabel, quantityTitleLabel, remainingTitleLabel].forEach {
            $0.font = .systemFont(ofSize: 12)
            $0.textColor = ThemeColor.label2
        }

        [priceValueLabel, quantityValueLabel, remainingValueLabel].forEach {
            $0.font = .systemFont(ofSize: 12, weight: .bold)
            $0.textColor = ThemeColor.label1
            $0.textAlignment = .right
        }

        priceTitleLabel.text = "주문가격"
        quantityTitleLabel.text = "주문수량"
        remainingTitleLabel.text = "미체결량"

        cancelButton.setTitle("취소", for: .normal)

        nameLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(8)
        }

        sideLabel.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel)
            make.leading.equalTo(nameLabel.snp.trailing).offset(4)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(8)
        }

        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel)
        }

        titleStack.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
            make.trailing.lessThanOrEqualTo(valueStack.snp.leading).offset(-8)
        }

        valueStack.snp.makeConstraints { make in
            make.top.equalTo(titleStack)
            make.trailing.equalToSuperview().inset(8)
            make.bottom.equalTo(titleStack)
        }
    }

    func bind(order: MyOrder, showCancel: Bool) {
        nameLabel.text = order.code

        if order.ask_bid == "ask" {
            sideLabel.text = "매도"
            sideLabel.textColor = ThemeColor.fallPrimary
        } else {
            sideLabel.text = "매수"
            sideLabel.textColor = ThemeColor.risePrimary
        }

        let date = Date(timeIntervalSince1970: Double(order.order_timestamp) / 1000)
        timeLabel.text = Self.dateFormatter.string(from: date)

        priceValueLabel.text = Decimal(order.price).formattedStringWithTruncation(places: 0)
        quantityValueLabel.text = Decimal(order.volume).formattedStringWithTruncation(places: 8)
        remainingValueLabel.text = Decimal(order.remaining_volume).formattedStringWithTruncation(places: 8)

        cancelButton.isHidden = !showCancel
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm:ss"
        return formatter
    }()
}

