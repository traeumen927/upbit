//
//  AccountTableDataSource.swift
//  upbit
//
//  Created by 홍정연 on 3/31/25.
//

import UIKit

enum AccountSection {
    case main
}

// MARK: MarketViewController의 TableViewDataSource
final class AccountTableDataSource: UITableViewDiffableDataSource<AccountSection, AccountTicker> {
    init(tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, account -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AccountCell.cellId, for: indexPath) as? AccountCell else {
                return UITableViewCell()
            }
            cell.configure(with: account)
            return cell
        }
    }
    
    // MARK: 스냅샷 업데이트
    func update(with accountTicker: [AccountTicker]) {
        var snapshot = NSDiffableDataSourceSnapshot<AccountSection, AccountTicker>()
        snapshot.appendSections([.main])
        snapshot.appendItems(accountTicker, toSection: .main)
        self.apply(snapshot, animatingDifferences: false)
    }
}
