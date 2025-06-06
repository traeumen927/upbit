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
    
    // MARK: 전달받은 메뉴 하위 페이지 배열
    private let pages: [UIViewController]
    
    // MARK: 현재가 라벨
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.text = " "
        label.textColor = ThemeColor.evenPrimary
        return label
    }()
    
    // MARK: 변동금액 라벨
    private lazy var changeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.text = " "
        label.textColor = ThemeColor.evenPrimary
        return label
    }()
    
    // MARK: 메뉴가 있는 PageView
    private lazy var menuPageView: MenuPageView = {
        let view = MenuPageView(menuTitles: ["주문", "차트", "호가", "거래내역", "종목토론방"], pages: self.pages)
        view.delegate = self
        
        return view
    }()
    
    
    // MARK: Initializer
    init(viewModel: DetailPageViewModel, pages: [UIViewController]) {
        self.viewModel = viewModel
        self.pages = pages
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.layout()
        self.bind()
    }
    
    // MARK: Layout Setup
    private func layout() {
        self.title = self.viewModel.marketInfo.koreanName
        
        view.backgroundColor = ThemeColor.background1
        
        // MARK: 상단 현재가, 변동금액 레이아웃 배치
        [self.priceLabel, self.changeLabel, self.menuPageView].forEach(self.view.addSubview(_:))
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        changeLabel.snp.makeConstraints { make in
            make.top.equalTo(self.priceLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        menuPageView.snp.makeConstraints { make in
            make.top.equalTo(self.changeLabel.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        menuPageView.configurePageViewController(with: self)
    }
    
    private func bind() {
        // MARK: 실시간 코인 현재가 구독
        self.viewModel.tickerSubject
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] ticker in
                guard let self = self else { return }
                updateTicker(with: ticker)
            }).disposed(by: disposeBag)
    }
    
    // MARK: 실시간 현재가에 따라 업데이트
    private func updateTicker(with ticker: SocketTicker) {
        self.priceLabel.text = "₩\(ticker.trade_price.formattedStringWithCommaAndDecimal(places: 6))"
        self.priceLabel.textColor = ticker.change.color
        
        self.changeLabel.text = "\(ticker.change.sign)\((ticker.change_rate * 100).formattedStringWithCommaAndDecimal(places: 2, removeZero: false))% (\(ticker.signed_change_price.formattedStringWithCommaAndDecimal(places: 8, removeZero: true)))"
        self.changeLabel.textColor = ticker.change.color
    }
    
    
    
    // MARK: 웹소켓 연결
    override func viewWillAppear(_ animated: Bool) {
        self.viewModel.connectWebSocket()
    }
    
    // MARK: 웹소켓 연결 해제
    override func viewWillDisappear(_ animated: Bool) {
        self.viewModel.disconnectWebSocket()
    }
}


// MARK: - Place for extension with MenuPageViewDelegate
extension DetailPageViewController: MenuPageViewDelegate {
    func menuPageView(_ menuPageView: MenuPageView, didSelectPageAt index: Int) {
        
    }
}
