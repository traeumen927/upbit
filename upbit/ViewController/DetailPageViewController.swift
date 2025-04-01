//
//  DetailPageViewController.swift
//  upbit
//
//  Created by 홍정연 on 4/1/25.
//

import UIKit
import RxSwift
import SnapKit


class DetailPageViewController: UIViewController {
    
    // MARK: ViewModel
    private let viewModel: DetailPageViewModel
    
    // MARK: disposeBag
    private let disposeBag = DisposeBag()
    
    // MARK: 코디네이터 참조
    weak var coordinator: DetailPageCoordinator?
    
    // MARK: 메뉴 및 페이지뷰 관련 프로퍼티
    private let menuTitles = ["메뉴1", "메뉴2", "메뉴3"] // 필요한 만큼 메뉴 추가
    private var menuButtons: [UIButton] = []
    private var indicatorView: UIView!
    private var menuStackView: UIStackView!
    
    private var pageViewController: UIPageViewController!
    private var pages: [UIViewController] = []
    private var currentPageIndex: Int = 0
    
    // 전환 중 여부 플래그 (스크롤 delegate 업데이트 무시용)
    private var isTransitioning: Bool = false
    
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
        
        // 내부 UIScrollView를 찾아 delegate 설정 (수동 스와이프 시 인디케이터 업데이트)
        if let scrollView = pageViewController.view.subviews.compactMap({ $0 as? UIScrollView }).first {
            scrollView.delegate = self
        }
    }
    
    // MARK: Layout Setup
    private func layout() {
        view.backgroundColor = ThemeColor.background1
    }
    
    // 메뉴 바 및 인디케이터 설정
    private func setupMenuBar() {
        let menuContainer = UIView()
        view.addSubview(menuContainer)
        menuContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        menuStackView = UIStackView()
        menuStackView.axis = .horizontal
        menuStackView.distribution = .fillEqually
        menuContainer.addSubview(menuStackView)
        menuStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        for (index, title) in menuTitles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(menuButtonTapped(_:)), for: .touchUpInside)
            menuStackView.addArrangedSubview(button)
            menuButtons.append(button)
        }
        
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
        let page1 = UIViewController()
        page1.view.backgroundColor = .blue
        let page2 = UIViewController()
        page2.view.backgroundColor = .green
        let page3 = UIViewController()
        page3.view.backgroundColor = .orange
        
        pages = [page1, page2, page3]
        
        pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                  navigationOrientation: .horizontal,
                                                  options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        pageViewController.setViewControllers([pages[0]], direction: .forward, animated: false, completion: nil)
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        pageViewController.view.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(50)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: 메뉴 버튼 액션
    @objc private func menuButtonTapped(_ sender: UIButton) {
        let targetIndex = sender.tag
        let direction: UIPageViewController.NavigationDirection = (targetIndex >= currentPageIndex) ? .forward : .reverse
        
        // 전환 애니메이션과 동시에 인디케이터 애니메이션 시작 (duration을 0.3초로 가정)
        let animationDuration = 0.3
        isTransitioning = true
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseInOut], animations: {
            let indicatorWidth = self.view.frame.width / CGFloat(self.menuTitles.count)
            self.indicatorView.frame.origin.x = indicatorWidth * CGFloat(targetIndex)
        }, completion: nil)
        
        pageViewController.setViewControllers([pages[targetIndex]], direction: direction, animated: true) { [weak self] finished in
            guard let self = self else { return }
            self.isTransitioning = false
            self.currentPageIndex = targetIndex
            // 최종 위치 보정
            self.updateIndicatorPosition(animated: false)
        }
    }
    
    // 인디케이터 위치 업데이트 (일반 스크롤 시)
    private func updateIndicatorPosition(animated: Bool) {
        let indicatorWidth = view.frame.width / CGFloat(menuTitles.count)
        let newLeading = indicatorWidth * CGFloat(currentPageIndex)
        UIView.animate(withDuration: animated ? 0.3 : 0.0) {
            self.indicatorView.frame.origin.x = newLeading
        }
    }
}

// MARK: UIPageViewControllerDataSource & Delegate
extension DetailPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else { return nil }
        return pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if completed, let currentVC = pageViewController.viewControllers?.first,
           let index = pages.firstIndex(of: currentVC) {
            currentPageIndex = index
            updateIndicatorPosition(animated: true)
        }
    }
}

// MARK: UIScrollViewDelegate - 스와이프 진행 중 인디케이터 업데이트
extension DetailPageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isTransitioning { return }
        let width = scrollView.frame.width
        let progress = (scrollView.contentOffset.x - width) / width
        let indicatorWidth = view.frame.width / CGFloat(menuTitles.count)
        let newLeading = indicatorWidth * (CGFloat(currentPageIndex) + progress)
        indicatorView.frame.origin.x = newLeading
    }
}
