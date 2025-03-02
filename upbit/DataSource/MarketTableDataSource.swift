//
//  MarketTableDataSource.swift
//  upbit
//
//  Created by 홍정연 on 2/25/25.
//

import UIKit

enum MarketSection {
    case main
}

// MARK: MarketViewController의 TableViewDataSource
final class MarketTableDataSource: UITableViewDiffableDataSource<MarketSection, MarketTicker> {
    init(tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, market -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MarketCell.cellId, for: indexPath) as? MarketCell else {
                return UITableViewCell()
            }
            cell.configure(with: market)
            return cell
        }
    }
    
    // MARK: 스냅샷 업데이트
    func update(with marketTicker: [MarketTicker]) {
        var snapshot = NSDiffableDataSourceSnapshot<MarketSection, MarketTicker>()
        snapshot.appendSections([.main])
        snapshot.appendItems(marketTicker, toSection: .main)
        self.apply(snapshot, animatingDifferences: false)
    }
}
