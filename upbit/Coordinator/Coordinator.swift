//
//  Coordinator.swift
//  upbit
//
//  Created by 홍정연 on 2/17/25.
//

import UIKit

// 모든 Coordinator가 따를 기본 프로토콜
// Coordinator는 화면 전환(네비게이션)과 초기 화면 구성을 담당
protocol Coordinator {
    // 화면 전환을 위한 UINavigationController를 보유
    var navigationController: UINavigationController { get set }
    
    // 해당 Coordinator의 시작(초기 화면 구성) 메서드
    func start()
}
