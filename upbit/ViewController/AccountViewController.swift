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
        
        // MARK: 보유한 자산 주제 구독
        self.viewModel.accountSubject
            .asObservable()
            .distinctUntilChanged { (prevAccounts, nextAccounts) -> Bool in
                // MARK: 1. Accounts의 배열의 갯수가 바뀌면 변경된 것으로 판단
                guard prevAccounts.count == nextAccounts.count else { return false }
                
                // MARK: 2. Accounts의 구성요소들의 종류, 수량, 매수평균가 등이 바뀌면 변경된 것으로 판단
                for (prev, next) in zip(prevAccounts, nextAccounts) {
                    if prev.currency != next.currency ||
                        prev.balance != next.balance ||
                        prev.avg_buy_price != next.avg_buy_price {
                        return false
                    }
                }
                
                // MARK: 3. 모두 같다면 변경되지 않은 것으로 판단
                return true
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] accounts in
                guard let self = self else { return }
                // MARK: 보유자산뷰 Configure
                self.accountAmountView.configure(accounts: accounts)
                
                // MARK: 파이차트뷰 Configure
                self.accountChartView.configure(accounts: accounts)
            }).disposed(by: disposeBag)
        
        // MARK: 보유한 코인의 ticker 구독, 0.25초 마다 이벤트 방출
        self.viewModel.tickerRelay
            .asObservable()
            .throttle(.milliseconds(250), latest: true, scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] tickers in
                guard let self = self else { return }
                // MARK: 보유자산뷰 update
                self.accountAmountView.update(tickers: tickers)
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
    
    // MARK: 데이터 configure
    func configure(accounts: [Account]) {
        self.accounts = accounts
        
        // MARK: 보유원화
        let krwVolume = self.accounts.first(where: { $0.currency == "KRW" })?.balance ?? 0
        
        // MARK: 원화를 제외한 코인들의 총 투자금액 계산 -> sum((주문가능수량 + 주문대기수량) * 평균구매가)
        let coinVolumeAmount = self.accounts.filter { $0.currency != "KRW"}.reduce(0) { sum, account in
            sum + ((account.balance + account.locked) * account.avg_buy_price)
        }
        
        self.totalLabel.text = "\(coinVolumeAmount.formattedStringWithCommaAndDecimal(places: 0))원"
        
        self.krwLabel.text = "보유원화 \(krwVolume.formattedStringWithCommaAndDecimal(places: 0))원"
        
        self.investLabel.text = "투자금액 \(coinVolumeAmount.formattedStringWithCommaAndDecimal(places: 0))원"
    }
    
    // MARK: 데이터 업데이트
    func update(tickers: [SocketTicker]) {
        
        tickers.forEach { ticker in
            tickerDictionary[ticker.code] = ticker
        }
        
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

// MARK: 총 보유 자산을 PieChart로 구성할 뷰
fileprivate class AccountChartView: UIView {
    
    // MARK: 최초 1회 configure로 저장하는 account 배열 객체
    private var accounts: [Account] = [Account]()
    
    // MARK: 각 코인별 최신 ticker 정보를 저장하기 위한 딕셔너리
    private var tickerDictionary: [String : SocketTicker] = [String : SocketTicker]()
    
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
    
    // MARK: 최초 1회 보유 자산을 매수가 기준으로 파이차트 엔트리 구성
    func configure(accounts: [Account]) {
        self.accounts = accounts
        
        let entries = accounts.compactMap { account -> PieChartDataEntry? in
            // MARK: 원화인경우 value -> (주문 가능 수량 + 주문중 묶인 수량) * 매수평균가
            // MARK: 코인인경우 value -> (주문 가능 수량 + 주문중 묶인 수량) * 매수평균가
            let value: Double = account.currency == "KRW" ? account.balance : (account.balance + account.locked) * account.avg_buy_price
            
            guard value > 0 else { return nil }
            return PieChartDataEntry(value: value, label: account.currency)
        }
        .sorted { $0.value > $1.value }
        
        if !entries.isEmpty {
            self.setData(entries: entries)
        }
    }
    
    // MARK: 데이터 업데이트
    func update(tickers: [SocketTicker]) {
        
        // MARK: tickerDictionary 업데이트
        tickers.forEach { ticker in
            tickerDictionary[ticker.code] = ticker
        }
        
        // MARK: 각 계좌의 최신 가치 계산 후 PieChartDataEntry 생성
        let entries = accounts.compactMap { account -> PieChartDataEntry? in
            var value: Double = 0.0
            
            if account.currency == "KRW" {
                // MARK:  원화 계좌: 단순 잔액 사용
                value = account.balance
            } else {
                // MARK:  코인 계좌: "KRW-BTC"와 같이 구성된 마켓코드 사용
                let marketCode = "\(account.unit_currency)-\(account.currency)"
                // MARK:  최신 ticker가 있으면 해당 가격으로 계산, 없으면 avg_buy_price 사용
                if let ticker = tickerDictionary[marketCode] {
                    value = (account.balance + account.locked) * ticker.trade_price
                } else {
                    value = (account.balance + account.locked) * account.avg_buy_price
                }
            }
            
            // MARK:  0 이하인 경우 제외
            guard value > 0 else { return nil }
            return PieChartDataEntry(value: value, label: account.currency)
        }
        .sorted { $0.value > $1.value }
        
        // MARK:  데이터가 있으면 차트에 반영
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
