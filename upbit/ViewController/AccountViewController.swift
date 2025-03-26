//
//  AccountViewController.swift
//  upbit
//
//  Created by 홍정연 on 2/17/25.
//

import UIKit
import RxSwift
import SnapKit

class AccountViewController: UIViewController {
    
    // MARK: ViewModel
    private let viewModel: AccountViewModel
    
    // MARK: disposeBag
    private let disposeBag = DisposeBag()
    
    // MARK: 스크롤뷰
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        return view
    }()
    
    // MARK: 스택뷰
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        return view
    }()
    
    // MARK: 1. 보유자산 뷰
    fileprivate let accountView:  AccountView = {
        let view = AccountView()
        return view
    }()
    
    init(viewModel: AccountViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.layout()
        self.bind()
    }
    
    // MARK: 레이아웃 설정
    private func layout() {
        self.title = "투자내역"
        
        // MARK: 스크롤뷰, 스택뷰 레이아웃
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        stackView.addArrangedSubview(accountView)
    }
    
    // MARK: 바인딩 설정
    private func bind() {
        
        // MARK: 보유한 자산 주제 구독
        self.viewModel.accountSubject
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] accounts in
                guard let self = self else { return }
                // MARK: 보유자산뷰 Configure
                self.accountView.configure(accounts: accounts)
            }).disposed(by: disposeBag)
        
        // MARK: 보유한 코인의 ticker 구독
        self.viewModel.tickerSubject
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] ticker in
                guard let self = self else { return }
                // MARK: 보유자산뷰 update
                self.accountView.update(ticker: ticker)
            }).disposed(by: disposeBag)
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


// MARK: 총 보유 자산이 보여질 UIVIew
fileprivate class AccountView: UIView {
    
    // MARK: 최초 1회 configure로 저장하는 account 배열 객체
    private var accounts: [Account] = [Account]()
    
    // MARK: 각 코인별 최신 ticker 정보를 저장하기 위한 딕셔너리
    private var tickerDictionary: [String : SocketTicker] = [String : SocketTicker]()
    
    // MARK: 타이틀 라벨
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeColor.label1
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = "내 보유자산"
        return label
    }()
    
    // MARK: 총 금액 라벨
    private lazy var totalLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeColor.label1
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.text = "0원"
        return label
    }()
    
    // MARK: 손익금액 라벨
    private lazy var changeLabel: UILabel = {
        let label = UILabel()
        label.textColor = ChangeType.even.color
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.text = "0% (0원)"
        return label
    }()
    
    // MARK: 투자금액 라벨
    private lazy var investLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeColor.tintDisable
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.text = "투자금액 0원"
        return label
    }()
    
    // MARK: 보유원화 라벨
    private lazy var krwLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeColor.tintDisable
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.text = "보유원화 0원"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        // MARK: 라벨 레이아웃
        [self.titleLabel, self.totalLabel, self.changeLabel, self.investLabel, self.krwLabel]
            .forEach(self.addSubview(_:))
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        self.totalLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        self.changeLabel.snp.makeConstraints { make in
            make.top.equalTo(self.totalLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        self.investLabel.snp.makeConstraints { make in
            make.top.equalTo(self.changeLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        self.krwLabel.snp.makeConstraints { make in
            make.top.equalTo(self.investLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    // MARK: 데이터 configure
    func configure(accounts: [Account]) {
        self.accounts = accounts
        
        // MARK: 보유원화
        let krwVolume = self.accounts.first(where: { $0.currency == "KRW" })?.balance ?? 0
        
        // MARK: 원화를 제외한 코인들의 총 투자금액 계산 -> sum((주문가능수량 + 주문대기수량) * 평균구매가)
        let coinVolumeAmount = self.accounts.filter { $0.currency != "KRW"}.reduce(0) { sum, account in
            sum + ((account.balance + account.locked) * account.avg_buy_price)
        }
        
        self.krwLabel.text = "보유원화 \(krwVolume.formattedStringWithCommaAndDecimal(places: 0))원"
        
        self.investLabel.text = "투자금액 \(coinVolumeAmount.formattedStringWithCommaAndDecimal(places: 0))원"
        
        print(accounts)
    }
    
    // MARK: 데이터 업데이트
    func update(ticker: SocketTicker) {
        tickerDictionary[ticker.code] = ticker
        
        // MARK: 보유원화
        let krwVolume = self.accounts.first(where: { $0.currency == "KRW" })?.balance ?? 0
        
        // MARK: 원화를 제외한 코인들의 총 투자금액 계산 -> sum((주문가능수량 + 주문대기수량) * 평균구매가)
        let coinVolumeAmount = self.accounts.filter { $0.currency != "KRW"}.reduce(0) { sum, account in
            sum + ((account.balance + account.locked) * account.avg_buy_price)
        }
        
        // MARK: 원화를 제외한 코인들의 현재가치, 실시간 가격이 있으면 사용하고, 없으면 매수 평균가 사용함
        let coinVolumeValue = self.accounts.filter { $0.currency != "KRW"}.reduce(0) { sum, account in
            let price = tickerDictionary["\(account.unit_currency)-\(account.currency)"]?.trade_price ?? account.avg_buy_price
            return sum + (account.balance + account.locked) * price
        }
        
        // MARK: 총 자산 = 보유원화 + 코인 현재가의 합
        let totalValue = krwVolume + coinVolumeValue
        
        // MARK: 수익률
        let changePercentage: Double = coinVolumeAmount > 0 ? ((coinVolumeValue - coinVolumeAmount) / coinVolumeAmount) * 100 : 0
        
        // MARK: 수익증감액
        let changeValue: Double = coinVolumeValue - coinVolumeAmount
        
        // MARK: 총 자산 배치
        self.totalLabel.text = "\(totalValue.formattedStringWithCommaAndDecimal(places: 0))원"
        
        // MARK: 수익률 배치
        self.changeLabel.text = "\(changePercentage.formattedStringWithCommaAndDecimal(places: 2, removeZero: false))% (\(changeValue.formattedStringWithCommaAndDecimal(places: 0))원)"
        
        // MARK: 수익률 색상 설정
        self.changeLabel.textColor = changeValue.changeType.color
        
        // MARK: 보유원화 배치
        self.krwLabel.text = "보유원화 \(krwVolume.formattedStringWithCommaAndDecimal(places: 0))원"
        
        
    }
}
