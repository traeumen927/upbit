//
//  AccountViewController.swift
//  upbit
//
//  Created by 홍정연 on 2/17/25.
//

import UIKit
import RxSwift
import SnapKit
import DGCharts

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
        view.axis = .vertical
        view.spacing = 10
        view.backgroundColor = ThemeColor.background2
        return view
    }()
    
    // MARK: 1. 보유자산 뷰
    fileprivate let accountAmountView: AccountAmountView = {
        let view = AccountAmountView()
        return view
    }()
    
    // MARK: 1. 보유자산 차트뷰
    fileprivate let accountChartView: AccountChartView = {
        let view = AccountChartView()
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
        
        [accountAmountView, accountChartView].forEach(self.stackView.addArrangedSubview(_:))
    }
    
    // MARK: 바인딩 설정
    private func bind() {
        
        // MARK: 보유원화 구독
        self.viewModel.accountKRWSubject
            .asObservable()
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] krwAccount in
                guard let self = self else { return }
                // MARK: 보유자산 뷰 원화 갱신
                self.accountAmountView.setKRW(account: krwAccount)
            }).disposed(by: disposeBag)
        
        // MARK: 보유한 자산 + 현재가 주제 구독
        self.viewModel.accountTickerRelay
            .asObservable()
            .throttle(.milliseconds(250), latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] accountTicker in
                guard let self = self else { return }
                
                // MARK: 보유자산 뷰 갱신
                self.accountAmountView.update(with: accountTicker)
                
                // MARK: 보유자산 파이차트 갱신
                self.accountChartView.update(with: accountTicker)
            }).disposed(by: disposeBag)
        
        // MARK: 메세지 구독
        self.viewModel.messageSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                self.view.makeToast(message, duration: 2.0, position: .bottom)
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
fileprivate class AccountAmountView: UIView {
    
    // MARK: 원화자산 프로퍼티
    private var krwAccount: Account?
    
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
        
        self.backgroundColor = ThemeColor.background1
        
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
    
    // MARK: 원화자산 업데이트
    func setKRW(account: Account) {
        self.krwAccount = account
        
        self.update()
    }
    
    // MARK: 데이터 업데이트
    func update(with accountTickers: [AccountTicker]? = nil) {
        
        guard let krwAccount = self.krwAccount else { return }
        
        // MARK: 코인 투자금액: 매수 평균가 기준
        let coinInvestedAmount = (accountTickers ?? []).reduce(0.0) { sum, accountTicker in
            sum + ((accountTicker.account.balance + accountTicker.account.locked) * accountTicker.account.avg_buy_price)
        }
        
        // MARK: 코인 현재 가치: ticker를 통한 현재가
        let coinCurrentValue = (accountTickers ?? []).reduce(0.0) { sum, accountTicker in
            let currentPrice = accountTicker.ticker.trade_price
            return sum + ((accountTicker.account.balance + accountTicker.account.locked) * currentPrice)
        }
        
        // MARK: 총 자산 = 보유원화 + 코인 현재가
        let totalValue = krwAccount.balance + coinCurrentValue
        let changeValue = coinCurrentValue - coinInvestedAmount
        let changePercentage = coinInvestedAmount > 0 ? (changeValue / coinInvestedAmount) * 100 : 0.0
        
        // MARK: 라벨 업데이트
        self.totalLabel.text = "\(totalValue.formattedStringWithCommaAndDecimal(places: 0))원"
        self.investLabel.text = "투자금액 \(coinInvestedAmount.formattedStringWithCommaAndDecimal(places: 0))원"
        self.changeLabel.text = "\(changePercentage.formattedStringWithCommaAndDecimal(places: 2, removeZero: false))% (\(changeValue.formattedStringWithCommaAndDecimal(places: 0))원)"
        self.changeLabel.textColor = changeValue.changeType.color
        self.krwLabel.text = "보유원화 \(krwAccount.balance.formattedStringWithCommaAndDecimal(places: 0))원"
    }
}

// MARK: 총 보유 자산을 PieChart로 구성할 뷰
fileprivate class AccountChartView: UIView {
    
    // MARK: 파이차트
    private var pieChart: PieChartView = {
        let view = PieChartView()
        view.noDataText = "보유한 코인이 없습니다."
        view.drawHoleEnabled = false
        view.rotationEnabled = false
        view.usePercentValuesEnabled = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        
        self.backgroundColor = ThemeColor.background1
        
        self.addSubview(pieChart)
        
        pieChart.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview().inset(24)
            make.height.equalTo(pieChart.snp.width)
        }
    }
    
    // MARK: 데이터 업데이트
    func update(with accountTickers: [AccountTicker]) {
        
        // MARK: 파이차트에 사용될 entries 구성, 현재가치가 높은 순으로 정렬
        let entries = accountTickers.compactMap { accountTicker -> PieChartDataEntry? in
            
            // MARK: 현재가치
            let currentPrice = accountTicker.ticker.trade_price
            
            let value = (accountTicker.account.balance + accountTicker.account.locked) * currentPrice
            guard value > 0 else { return nil }
            return PieChartDataEntry(value: value, label: accountTicker.account.currency)
        }.sorted { $0.value > $1.value }
        
        if !entries.isEmpty {
            setData(entries: entries)
        }
    }
    
    func setData(entries: [PieChartDataEntry]) {
        
        // MARK: 데이터셋 설정
        let dataSet = PieChartDataSet(entries: entries, label: "")
        dataSet.drawValuesEnabled = true
        dataSet.colors = ChartColorTemplates.vordiplom() +
        ChartColorTemplates.joyful() +
        ChartColorTemplates.liberty() +
        ChartColorTemplates.pastel()
        
        // MARK: 데이터셋 기반으로 데이터 객세 생성
        let data = PieChartData(dataSet: dataSet)
        data.setValueTextColor(ThemeColor.label1)
        data.setValueFont(.systemFont(ofSize: 12, weight: .medium))
        data.setValueFormatter(PercentFormatter(chart: self.pieChart))
        self.pieChart.data = data
    }
}
