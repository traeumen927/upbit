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
        let orderViewController = OrderViewController(viewModel: OrderViewModel())
        let chartViewController = ChartViewController(viewModel: ChartViewModel())
        let orderBookViewController = OrderBookViewController(viewModel: OrderBookViewModel())
        let chatViewController = ChatViewController(viewModel: ChatViewModel())
        
        // MARK: 각 하위 controller 배열
        let pages = [orderViewController, chartViewController, orderBookViewController, chatViewController]
        
        let viewController = DetailPageViewController(viewModel: viewModel, pages: pages)
        viewController.coordinator = self
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
    }
}
