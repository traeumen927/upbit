//
//  DetailPageCoordinator.swift
//  upbit
//
//  Created by 홍정연 on 4/1/25.
//

import UIKit

class DetailPageCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    private let marketInfo: MarketInfo
    
    init(navigationController: UINavigationController, marketInfo: MarketInfo) {
        self.navigationController = navigationController
        self.marketInfo = marketInfo
    }
    
    func start() {
        // MARK: DetailPageViewModel
        let viewModel = DetailPageViewModel(marketInfo: self.marketInfo)
        
        // MARK: 각 하위 PageViewController들
        
        // MARK: 주문 페이지
        let orderViewController = OrderViewController(viewModel:
                                                        OrderViewModel(market: self.marketInfo.market,
                                                                       tickerObservable:  viewModel.tickerSubject.asObservable(),
                                                                       orderbookObservable: viewModel.orderbookSubject.asObservable(),
                                                                       myOrderObservable: viewModel.myOrderSubject.asObservable()))
        
        // MARK: 차트 페이지
        let chartViewController = ChartViewController(viewModel: ChartViewModel())
        
        // MARK: 호가 페이지
        let orderBookViewController = OrderBookViewController(viewModel: OrderBookViewModel())
        
        // MARK: 거래내역 페이지
        let historyViewController = HistoryViewController(viewModel: HistoryViewModel(myOrderObservable: viewModel.myOrderSubject.asObservable()))
        
        // MARK: 종목토론방 페이지
        let chatViewController = ChatViewController(viewModel: ChatViewModel())
        
        // MARK: 각 하위 controller 배열
        let pages = [orderViewController, chartViewController, orderBookViewController, historyViewController, chatViewController]
        
        let viewController = DetailPageViewController(viewModel: viewModel, pages: pages)
        viewController.coordinator = self
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
    }
}
