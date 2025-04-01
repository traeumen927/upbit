//
//  AccountCoordinator.swift
//  upbit
//
//  Created by 홍정연 on 4/1/25.
//

import UIKit

class AccountCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = AccountViewModel()
        let viewController = AccountViewController(viewModel: viewModel)
        viewController.tabBarItem = UITabBarItem(title: "투자내역", image: UIImage(systemName: "chart.pie"), tag: 1)
        viewController.coordinator = self
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func showDetail() {
        let detailCoordinator = DetailPageCoordinator(navigationController: UINavigationController())
        detailCoordinator.start()
        
        self.navigationController.present(detailCoordinator.navigationController, animated: true)
    }
}
