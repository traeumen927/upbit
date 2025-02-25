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
final class MarketTableDataSource: UITableViewDiffableDataSource<MarketSection, Market> {
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
    func update(with markets: [Market]) {
        var snapshot = NSDiffableDataSourceSnapshot<MarketSection, Market>()
        snapshot.appendSections([.main])
        snapshot.appendItems(markets, toSection: .main)
        self.apply(snapshot, animatingDifferences: false)
    }
}
