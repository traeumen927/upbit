//
//  AccountCoordinator.swift
//  upbit
//
//  Created by 홍정연 on 4/1/25.
//

import UIKit

class SettingCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = SettingViewModel()
        let viewController = SettingViewController(viewModel: viewModel)
        viewController.tabBarItem = UITabBarItem(title: "설정", image: UIImage(systemName: "gear"), tag: 2)
        viewController.coordinator = self
        
        navigationController.setViewControllers([viewController], animated: false)
    }
}
