//
//  DetailPageCoordinator.swift
//  upbit
//
//  Created by 홍정연 on 4/1/25.
//

import UIKit

class DetailPageCoordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = DetailPageViewModel()
        let viewController = DetailPageViewController(viewModel: viewModel)
        viewController.coordinator = self
        
        navigationController.setViewControllers([viewController], animated: false)
    }
}
