//
//  MenuPageView.swift
//  upbit
//
//  Created by 홍정연 on 4/7/25.
//

import UIKit
import SnapKit

protocol MenuPageViewDelegate: AnyObject {
    func menuPageView(_ menuPageView: MenuPageView, didSelectPageAt index: Int)
}

class MenuPageView: UIView {

    // MARK: Properties
    private let menuTitles: [String]
    private var pages: [UIViewController]
    
    private var menuButtons: [UIButton] = []
    private var indicatorView: UIView!
    private var menuStackView: UIStackView!
    
    let pageViewController: UIPageViewController
    private(set) var currentPageIndex: Int = 0
    private var isTransitioning: Bool = false
    
    weak var delegate: MenuPageViewDelegate?
    
    // Container view for pageViewController's view
    private let pageContainerView = UIView()
    
    // MARK: Initializer
    init(menuTitles: [String], pages: [UIViewController]) {
        self.menuTitles = menuTitles
        self.pages = pages
        self.pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                       navigationOrientation: .horizontal,
                                                       options: nil)
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 부모 뷰 컨트롤러에 pageViewController를 컨테이너로 추가하도록 설정하는 메서드
    // DetailPageViewController의 viewDidLoad()에서 호출할 것
    func configurePageViewController(with parentViewController: UIViewController) {
        parentViewController.addChild(pageViewController)
        pageContainerView.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        pageViewController.didMove(toParent: parentViewController)
        
        // 내부 UIScrollView delegate 설정
        if let scrollView = pageViewController.view.subviews.compactMap({ $0 as? UIScrollView }).first {
            scrollView.delegate = self
        }
    }
    
    // MARK: Setup Views
    private func setupViews() {
        // 1. 메뉴 컨테이너: 상단 50 포인트 영역
        let menuContainer = UIView()
        addSubview(menuContainer)
        menuContainer.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        // 2. 메뉴 스택뷰: 메뉴 버튼들을 담음
        menuStackView = UIStackView()
        menuStackView.axis = .horizontal
        menuStackView.distribution = .fillEqually
        menuContainer.addSubview(menuStackView)
        menuStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 3. 각 메뉴 버튼 생성
        for (index, title) in menuTitles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.setTitleColor(ThemeColor.label1, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            button.tag = index
            button.addTarget(self, action: #selector(menuButtonTapped(_:)), for: .touchUpInside)
            menuStackView.addArrangedSubview(button)
            menuButtons.append(button)
        }
        
        // 4. 메뉴 하단 인디케이터
        indicatorView = UIView()
        indicatorView.backgroundColor = ThemeColor.evenPrimary
        menuContainer.addSubview(indicatorView)
        indicatorView.snp.makeConstraints { make in
            make.height.equalTo(2)
            make.bottom.equalTo(menuContainer)
            make.width.equalTo(menuContainer.snp.width).multipliedBy(1.0 / CGFloat(menuTitles.count))
            make.leading.equalTo(menuContainer)
        }
        
        // 5. 페이지 컨테이너 뷰: 메뉴 컨테이너 아래 영역 전체
        addSubview(pageContainerView)
        pageContainerView.snp.makeConstraints { make in
            make.top.equalTo(menuContainer.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        // 6. 페이지 뷰 컨트롤러 초기 설정
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.setViewControllers([pages[0]], direction: .forward, animated: false, completion: nil)
    }
    
    // MARK: 메뉴 버튼 액션
    @objc private func menuButtonTapped(_ sender: UIButton) {
        let targetIndex = sender.tag
        let direction: UIPageViewController.NavigationDirection = (targetIndex >= currentPageIndex) ? .forward : .reverse
        isTransitioning = true
        
        // 동시에 인디케이터 애니메이션 실행 (duration 0.3초)
        let animationDuration = 0.3
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseInOut], animations: {
            let indicatorWidth = self.frame.width / CGFloat(self.menuTitles.count)
            self.indicatorView.frame.origin.x = indicatorWidth * CGFloat(targetIndex)
        }, completion: nil)
        
        pageViewController.setViewControllers([pages[targetIndex]], direction: direction, animated: true) { [weak self] finished in
            guard let self = self else { return }
            self.isTransitioning = false
            self.currentPageIndex = targetIndex
            self.updateIndicatorPosition(animated: false)
            self.delegate?.menuPageView(self, didSelectPageAt: targetIndex)
        }
    }
    
    private func updateIndicatorPosition(animated: Bool) {
        let indicatorWidth = self.frame.width / CGFloat(menuTitles.count)
        let newLeading = indicatorWidth * CGFloat(currentPageIndex)
        UIView.animate(withDuration: animated ? 0.3 : 0.0) {
            self.indicatorView.frame.origin.x = newLeading
        }
    }
    
    // Public method: 프로그래밍적 페이지 전환
    func setPage(index: Int, animated: Bool) {
        guard index >= 0 && index < pages.count else { return }
        let direction: UIPageViewController.NavigationDirection = (index >= currentPageIndex) ? .forward : .reverse
        isTransitioning = true
        pageViewController.setViewControllers([pages[index]], direction: direction, animated: animated) { [weak self] finished in
            guard let self = self else { return }
            self.isTransitioning = false
            self.currentPageIndex = index
            self.updateIndicatorPosition(animated: animated)
            self.delegate?.menuPageView(self, didSelectPageAt: index)
        }
    }
}

// MARK: UIPageViewControllerDataSource & Delegate
extension MenuPageView: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
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
        if completed,
           let currentVC = pageViewController.viewControllers?.first,
           let index = pages.firstIndex(of: currentVC) {
            currentPageIndex = index
            updateIndicatorPosition(animated: true)
            delegate?.menuPageView(self, didSelectPageAt: index)
        }
    }
}

// MARK: UIScrollViewDelegate - 인디케이터 업데이트 중
extension MenuPageView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isTransitioning { return }
        let width = scrollView.frame.width
        let progress = (scrollView.contentOffset.x - width) / width
        let indicatorWidth = self.frame.width / CGFloat(menuTitles.count)
        let newLeading = indicatorWidth * (CGFloat(currentPageIndex) + progress)
        indicatorView.frame.origin.x = newLeading
    }
}
