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
        let viewModel = DetailPageViewModel(marketInfo: self.marketInfo)
        let viewController = DetailPageViewController(viewModel: viewModel)
        viewController.coordinator = self
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
    }
}
