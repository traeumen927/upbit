//
//  OrderTableDataSource.swift
//  upbit
//
//  Created by 홍정연 on 4/10/25.
//

import Foundation

import UIKit

// MARK: - Section 정의
enum OrderbookSection {
    case main
}

// MARK: - Row 모델 (각 셀에 대한 고유 식별을 위해 UUID 사용)
struct OrderbookRow: Hashable {
    let orderbook: obUnits
    let isAsk: Bool
    let ticker: SocketTicker
    let id = UUID()
}

// MARK: - Diffable Data Source 클래스
final class OrderBookTableDataSource: UITableViewDiffableDataSource<OrderbookSection, OrderbookRow> {
    private var maxSize: Double = 0
    
    // 데이터소스 초기화 및 cellProvider 설정 (초기 ticker 전달 없이 생성)
    init(tableView: UITableView) {
        super.init(tableView: tableView, cellProvider: { (tableView, indexPath, row) -> UITableViewCell? in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OrderCell.cellId, for: indexPath) as? OrderCell,
                  let dataSource = tableView.dataSource as? OrderBookTableDataSource else {
                return UITableViewCell()
            }
            
            // 매도(ask)인지 매수(bid)인지에 따라 가격과 잔량 결정
            let price = row.isAsk ? row.orderbook.ask_price : row.orderbook.bid_price
            let size  = row.isAsk ? row.orderbook.ask_size  : row.orderbook.bid_size
            
            // latestTicker는 combinedOrderbookWithTicker가 방출된 이후 업데이트되므로, 여기서는 non-optional로 사용
            cell.configure(price: price, ticker: row.ticker, size: size, maxSize: dataSource.maxSize, isAsk: row.isAsk)
            
            // 최신 ticker의 trade_price와 셀에 표시되는 price가 같으면 테두리 강조
            if row.ticker.trade_price == price {
                cell.layer.borderWidth = 1.0
                cell.layer.borderColor = ThemeColor.evenPrimary.cgColor
            } else {
                cell.layer.borderWidth = 0.0
            }
            return cell
        })
    }
    
    // MARK: Snapshot 업데이트 메서드
    /// orderbook 데이터와 최신 ticker 값을 전달받아 snapshot을 갱신합니다.
    func update(with orderbook: Orderbook, latestTicker: SocketTicker) {
        
        // orderbook_units에서 최대 잔량 계산 (ask, bid 각각의 값 중 최대값)
        if !orderbook.orderbook_units.isEmpty {
            self.maxSize = orderbook.orderbook_units.map { max($0.ask_size, $0.bid_size) }.max() ?? 0
        } else {
            self.maxSize = 0
        }
        
        // ask측은 orderbook_units를 역순으로, bid측은 그대로 매핑해서 row 모델 생성
        let askRows = orderbook.orderbook_units.reversed().map { OrderbookRow(orderbook: $0, isAsk: true, ticker: latestTicker) }
        let bidRows = orderbook.orderbook_units.map { OrderbookRow(orderbook: $0, isAsk: false, ticker: latestTicker) }
        let allRows = askRows + bidRows
        
        // snapshot 구성 및 적용
        var snapshot = NSDiffableDataSourceSnapshot<OrderbookSection, OrderbookRow>()
        snapshot.appendSections([.main])
        snapshot.appendItems(allRows, toSection: .main)
        apply(snapshot, animatingDifferences: true)
    }
}
