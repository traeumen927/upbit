//
//  DetailPageViewController.swift
//  upbit
//
//  Created by 홍정연 on 4/1/25.
//

import UIKit
import RxSwift
import SnapKit
import DGCharts

class DetailPageViewController: UIViewController {
    
     // MARK: ViewModel
     private let viewModel: DetailPageViewModel
     
     // MARK: disposeBag
     private let disposeBag = DisposeBag()
     
     // MARK: 코디네이터 참조
     weak var coordinator: DetailPageCoordinator?
     
     // MARK: 메뉴 및 페이지뷰 관련 프로퍼티
     private let menuTitles = ["메뉴1", "메뉴2", "메뉴3"] // n개의 메뉴 타이틀 (필요에 따라 변경)
     private var menuButtons: [UIButton] = []
     private var indicatorView: UIView!
     private var menuStackView: UIStackView!
     
     private var pageViewController: UIPageViewController!
     private var pages: [UIViewController] = []
     private var currentPageIndex: Int = 0
     
     // MARK: Initializer
     init(viewModel: DetailPageViewModel) {
         self.viewModel = viewModel
         super.init(nibName: nil, bundle: nil)
     }
     
     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
         
     // MARK: Lifecycle
     override func viewDidLoad() {
         super.viewDidLoad()
         layout()
         setupMenuBar()
         setupPageViewController()
     }
     
     // MARK: Layout Setup
     private func layout() {
         view.backgroundColor = .black
     }
     
     // 메뉴 바 및 인디케이터 설정
     private func setupMenuBar() {
         // 메뉴 컨테이너 생성
         let menuContainer = UIView()
         view.addSubview(menuContainer)
         menuContainer.snp.makeConstraints { make in
             make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
             make.leading.trailing.equalToSuperview()
             make.height.equalTo(50) // 메뉴 바 높이
         }
         
         // 메뉴 버튼을 담을 스택뷰 생성
         menuStackView = UIStackView()
         menuStackView.axis = .horizontal
         menuStackView.distribution = .fillEqually
         menuContainer.addSubview(menuStackView)
         menuStackView.snp.makeConstraints { make in
             make.edges.equalToSuperview()
         }
         
         // 메뉴 타이틀에 따른 버튼 생성
         for (index, title) in menuTitles.enumerated() {
             let button = UIButton(type: .system)
             button.setTitle(title, for: .normal)
             button.setTitleColor(.white, for: .normal)
             button.tag = index
             button.addTarget(self, action: #selector(menuButtonTapped(_:)), for: .touchUpInside)
             menuStackView.addArrangedSubview(button)
             menuButtons.append(button)
         }
         
         // 메뉴 하단 인디케이터 생성
         indicatorView = UIView()
         indicatorView.backgroundColor = .red
         menuContainer.addSubview(indicatorView)
         indicatorView.snp.makeConstraints { make in
             make.height.equalTo(2)
             make.bottom.equalTo(menuContainer)
             make.width.equalTo(menuContainer.snp.width).multipliedBy(1.0 / CGFloat(menuTitles.count))
             make.leading.equalTo(menuContainer)
         }
     }
     
     // PageViewController 설정
     private func setupPageViewController() {
         // 예시용으로 각 페이지는 다른 배경색을 가진 단순 뷰 컨트롤러로 생성
         let page1 = UIViewController()
         page1.view.backgroundColor = .blue
         let page2 = UIViewController()
         page2.view.backgroundColor = .green
         let page3 = UIViewController()
         page3.view.backgroundColor = .orange
         
         pages = [page1, page2, page3]
         
         // UIPageViewController 초기화 (가로 스와이프)
         pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
         pageViewController.dataSource = self
         pageViewController.delegate = self
         
         // 초기 페이지 설정
         pageViewController.setViewControllers([pages[0]], direction: .forward, animated: false, completion: nil)
         
         // pageViewController를 자식 뷰 컨트롤러로 추가
         addChild(pageViewController)
         view.addSubview(pageViewController.view)
         pageViewController.didMove(toParent: self)
         
         // 레이아웃: 메뉴 바 바로 아래부터 전체 영역 차지
         pageViewController.view.snp.makeConstraints { make in
             make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(50)
             make.leading.trailing.bottom.equalToSuperview()
         }
     }
     
     // MARK: 메뉴 버튼 액션
     @objc private func menuButtonTapped(_ sender: UIButton) {
         let index = sender.tag
         let direction: UIPageViewController.NavigationDirection = (index >= currentPageIndex) ? .forward : .reverse
         currentPageIndex = index
         pageViewController.setViewControllers([pages[index]], direction: direction, animated: true, completion: nil)
         updateIndicatorPosition(animated: true)
     }
     
     // 인디케이터 위치 업데이트 (애니메이션)
     private func updateIndicatorPosition(animated: Bool) {
         let indicatorWidth = view.frame.width / CGFloat(menuTitles.count)
         let newLeading = indicatorWidth * CGFloat(currentPageIndex)
         // SnapKit의 업데이트 대신, 인디케이터의 프레임을 애니메이션 처리
         UIView.animate(withDuration: animated ? 0.3 : 0.0) {
             self.indicatorView.frame.origin.x = newLeading
         }
     }
 }

 // MARK: UIPageViewControllerDataSource & Delegate
 extension DetailPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
     // 이전 페이지 반환
     func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
         guard let index = pages.firstIndex(of: viewController), index > 0 else { return nil }
         return pages[index - 1]
     }
     
     // 다음 페이지 반환
     func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
         guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else { return nil }
         return pages[index + 1]
     }
     
     // 스와이프가 완료되었을 때 현재 페이지 인덱스 업데이트
     func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
         if completed, let currentVC = pageViewController.viewControllers?.first, let index = pages.firstIndex(of: currentVC) {
             currentPageIndex = index
             updateIndicatorPosition(animated: true)
         }
     }
 }
