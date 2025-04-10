//
//  MainTabBarCoordinator.swift
//  upbit
//
//  Created by 홍정연 on 2/17/25.
//

import UIKit

// MARK: 탭바와 각 탭의 네비게이션 흐름을 관리
class MainTabBarCoordinator {
    
    private var marketCoordinator: MarketCoordinator?
    private var accountCoordinator: AccountCoordinator?
    private var settingCoordinator: SettingCoordinator?
    
    
    func start() -> UITabBarController {
        let tabBarController = UITabBarController()
        
        // 자식 코디네이터 인스턴스를 생성하고 강한 참조를 유지
        let marketCoordinator = MarketCoordinator(navigationController: UINavigationController())
        let accountCoordinator = AccountCoordinator(navigationController: UINavigationController())
        let settingCoordinator = SettingCoordinator(navigationController: UINavigationController())
        
        self.marketCoordinator = marketCoordinator
        self.accountCoordinator = accountCoordinator
        self.settingCoordinator = settingCoordinator
        
        marketCoordinator.start()
        accountCoordinator.start()
        settingCoordinator.start()
        
        tabBarController.viewControllers = [marketCoordinator.navigationController,
                                            accountCoordinator.navigationController,
                                            settingCoordinator.navigationController]
        
        // 탭바 appearance 설정
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
        
        return tabBarController
    }
    
    
    // MARK: 코디네이터가 시작되어 탭바 컨트를러를 구성하고 반환하는 메서드
    func start2() -> UITabBarController {
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
