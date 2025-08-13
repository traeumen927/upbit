//
//  HistoryCell.swift
//  upbit
//
//  Created by OpenAI on 2024.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class HistoryCell: UITableViewCell {
    static let cellId = "HistoryCell"

    let coinLabel = UILabel()
    let priceLabel = UILabel()
    let executedLabel = UILabel()
    let remainingLabel = UILabel()
    let cancelButton = UIButton(type: .system)

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
        [coinLabel, priceLabel, executedLabel, remainingLabel, cancelButton].forEach(contentView.addSubview)

        coinLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(8)
        }

        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(coinLabel.snp.bottom).offset(4)
            make.leading.equalTo(coinLabel)
        }

        executedLabel.snp.makeConstraints { make in
            make.centerY.equalTo(coinLabel)
            make.trailing.equalToSuperview().inset(8)
        }

        remainingLabel.snp.makeConstraints { make in
            make.centerY.equalTo(priceLabel)
            make.trailing.equalTo(executedLabel)
        }

        cancelButton.setTitle("취소", for: .normal)
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(remainingLabel.snp.bottom).offset(8)
            make.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
        }
    }

    func configure(order: MyOrder, showCancel: Bool) {
        coinLabel.text = order.code
        priceLabel.text = Decimal(order.price).formattedStringWithTruncation(places: 0)
        executedLabel.text = "체결: \(Decimal(order.executed_volume).formattedStringWithTruncation(places: 8))"
        remainingLabel.text = "미체결: \(Decimal(order.remaining_volume).formattedStringWithTruncation(places: 8))"
        cancelButton.isHidden = !showCancel
    }
}

