//
//  UIViewController.swift
//  upbit
//
//  Created by 홍정연 on 2/17/25.
//

import UIKit

extension UIViewController {
    // MARK: 현재 뷰 컨트롤러를 내비게이션 컨트롤러로 감싸서 반환
    func wrappedInNavigationController() -> UINavigationController {
        return UINavigationController(rootViewController: self)
    }
}
