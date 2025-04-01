//
//  MarketCoordinator.swift
//  upbit
//
//  Created by 홍정연 on 4/1/25.
//

import UIKit

class MarketCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = MarketViewModel()
        let viewController = MarketViewController(viewModel: viewModel)
        viewController.tabBarItem = UITabBarItem(title: "거래소", image: UIImage(systemName: "bitcoinsign"), tag: 0)
        viewController.coordinator = self
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func showDetail() {
        let detailCoordinator = DetailPageCoordinator(navigationController: UINavigationController())
        detailCoordinator.start()
        
        self.navigationController.present(detailCoordinator.navigationController, animated: true)
    }
}
