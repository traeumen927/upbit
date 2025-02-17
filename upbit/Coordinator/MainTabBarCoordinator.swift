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
        let marketViewModel = MarketViewModel()
        let marketViewController = MarketViewController(viewModel: marketViewModel)
        marketViewController.tabBarItem = UITabBarItem(title: "거래소", image: UIImage(systemName: "bitcoinsign"), tag: 0)
        
        // MARK: - 투자내역 탭
        let accountViewModel = AccountViewModel()
        let accountViewController = AccountViewController(viewModel: accountViewModel)
        accountViewController.tabBarItem = UITabBarItem(title: "투자내역", image: UIImage(systemName: "chart.pie"), tag: 1)
        
        // MARK: - 설정 탭
        let settingViewModel = SettingViewModel()
        let settingViewController = SettingViewController(viewModel: settingViewModel)
        settingViewController.tabBarItem = UITabBarItem(title: "설정", image: UIImage(systemName: "gear"), tag: 2)
        
        // MARK: - 탭바 컨트롤러에 각 네비게이션 컨트롤러를 추가
        tabBarController.viewControllers = [marketViewController.wrappedInNavigationController(),
                                            accountViewController.wrappedInNavigationController(),
                                            settingViewController.wrappedInNavigationController()]
        
        // MARK: appearance 설정
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
        
        return tabBarController
    }
}
