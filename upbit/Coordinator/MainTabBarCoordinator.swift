//
//  MainTabBarCoordinator.swift
//  upbit
//
//  Created by 홍정연 on 2/17/25.
//

import UIKit

// MARK: 탭바와 각 탭의 네비게이션 흐름을 관리
class MainTabBarCoordinator {
    // MARK: 코디네이터가 시작되어 탭바 컨트를러를 구성하고 반환하는 메서드
    func start() -> UITabBarController {
        let tabBarController = UITabBarController()
        
        // MARK: - 거래소 탭
        let marketCoordinator = MarketCoordinator(navigationController: UINavigationController())
        marketCoordinator.start()
        
        // MARK: - 투자내역 탭
        let accountCoordinator = AccountCoordinator(navigationController: UINavigationController())
        accountCoordinator.start()
        
        // MARK: - 설정 탭
        let settingCoordinator = SettingCoordinator(navigationController: UINavigationController())
        settingCoordinator.start()
        
        // MARK: - 탭바 컨트롤러에 각 네비게이션 컨트롤러를 추가
        tabBarController.viewControllers = [marketCoordinator.navigationController,
                                            accountCoordinator.navigationController,
                                            settingCoordinator.navigationController]
        
        // MARK: appearance 설정
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
        
        return tabBarController
    }
}
