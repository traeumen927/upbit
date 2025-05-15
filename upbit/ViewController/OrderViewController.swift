//
//  OrderViewController.swift
//  upbit
//
//  Created by 홍정연 on 4/10/25.
//

import UIKit
import RxSwift

class OrderViewController: UIViewController {
    
    // MARK: ViewModel
    private let viewModel: OrderViewModel
    
    // MARK: disposeBag
    private let disposeBag = DisposeBag()
    
    // MARK: 호가정보
    private var orderbookUnits: [obUnits] = [obUnits]()
    
    // MARK: 현재가
    private var ticker:SocketTicker?
    
    // MARK: 호가창 가운데 정렬 여부
    private var isAlignCenter:Bool = false
    
    // MARK: 선택된 기준가
    private var seletedPrice: Double = 0.0 {
        didSet {
            // MARK: 기준가 업데이트
            self.priceTextFeild.text = "₩\(seletedPrice.formattedStringWithDecimal())"
        }
    }
    
    
    // MARK: 호가 테이블뷰
    private lazy var tableView: UITableView = {
        let tableview = UITableView()
        tableview.register(OrderCell.self, forCellReuseIdentifier: OrderCell.cellId)
        tableview.backgroundColor = .clear
        tableview.showsVerticalScrollIndicator = false
        tableview.separatorStyle = .none
        tableview.delegate = self
        tableview.dataSource = self
        tableview.contentInsetAdjustmentBehavior = .never
        return tableview
    }()
    
    // MARK: 매수/매도 컨트롤러
    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["매수", "매도"])
        control.selectedSegmentIndex = 0
        
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: ThemeColor.label2
        ]
        
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: ThemeColor.label1
        ]
        
        control.setTitleTextAttributes(normalAttributes, for: .normal)
        control.setTitleTextAttributes(selectedAttributes, for: .selected)
        
        return control
    }()
    
    // MARK: 매수/매도 버튼
    private lazy var orderButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.layer.cornerRadius = 8
        button.setTitleColor(.white, for: .normal)
        
        return button
    }()
    
    // MARK: 기준가 타이틀
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = ThemeColor.label1
        label.textAlignment = .left
        label.text = "기준가"
        
        return label
    }()
    
    // MARK: 기준가 텍스트
    private lazy var priceTextFeild: BorderedTextField = {
        let textField = BorderedTextField()
        textField.alignment = .right
        textField.keyboardType = .decimalPad
        textField.font = .systemFont(ofSize: 14, weight: .medium)
        textField.isInteractionEnabled = false
        
        return textField
    }()
    
    
    // MARK: 거래 수량 타이틀
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = ThemeColor.label1
        label.textAlignment = .left
        
        return label
    }()
    
    // MARK: 거래 수량 텍스트
    private lazy var amountTextFeild: BorderedTextField = {
        let textField = BorderedTextField()
        textField.alignment = .right
        textField.keyboardType = .decimalPad
        textField.font = .systemFont(ofSize: 14, weight: .medium)
        return textField
    }()
    
    // MARK: 거래 비중 슬라이더
    private lazy var orderSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        
        return slider
    }()
    
    init(viewModel: OrderViewModel) {
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
    
    private func layout() {
        
        // MARK: 매수/매도 페이지 바탕
        let orderBackgroundView: UIView = UIView()
        orderBackgroundView.backgroundColor = ThemeColor.background2
        
        // MARK: 매수/매도 페이지
        let orderView: UIView = UIView()
        orderView.backgroundColor = ThemeColor.background1
        orderView.layer.cornerRadius = 12
        orderView.layer.applySketchShadow(color: ThemeColor.tintDark,
                                          alpha: 0.08,
                                          x: 0,
                                          y: 4,
                                          blur: 24,
                                          spread: 0)
        
        // MARK: 매수/매도 구성요소 스택뷰
        let orderStackView = UIStackView()
        orderStackView.axis = .vertical
        orderStackView.spacing = 6
        
        [self.tableView, orderBackgroundView].forEach(self.view.addSubview(_:))
        orderBackgroundView.addSubview(orderView)
        [self.segmentedControl, orderStackView, self.orderButton].forEach(orderView.addSubview(_:))
        [self.priceLabel, self.priceTextFeild, UIView(), self.amountLabel, self.amountTextFeild, self.orderSlider].forEach(orderStackView.addArrangedSubview(_:))
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.45)
        }
        
        orderBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(self.tableView.snp.top)
            make.leading.equalTo(self.tableView.snp.trailing)
            make.trailing.bottom.equalToSuperview()
        }
        
        orderView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.greaterThanOrEqualToSuperview().offset(-50)
        }
        
        segmentedControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(8)
        }
        
        orderStackView.snp.makeConstraints { make in
            make.top.equalTo(self.segmentedControl.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(8)
        }
        
        orderButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(48)
        }
    }
    
    private func bind() {
        
        // MARK: 호가 구독, 0.25초 마다 이벤트 방출
        self.viewModel.orderbookObservable
            .throttle(.milliseconds(250), latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] orderbook in
                guard let self = self else { return }
                self.orderbookUnits = orderbook.orderbook_units
                self.tableView.reloadData()
                // MARK: 최초 1회 가운데 정렬
                if !isAlignCenter { centerTableView() }
            }).disposed(by: disposeBag)
        
        // MARK: 현재가 구독
        self.viewModel.tickerObservable
            .subscribe(onNext: { [weak self] ticker in
                guard let self = self else { return }
                self.ticker = ticker
            }).disposed(by: disposeBag)
        
        // MARK: 현재가 구독 (1회용)
        self.viewModel.tickerObservable
            .take(1)
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] ticker in
                self?.seletedPrice = ticker.trade_price
            })
            .disposed(by: disposeBag)
        
        // MARK: segmentedControl Index 구독
        self.segmentedControl.rx.selectedSegmentIndex
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                
                // MARK: 매수(index == 0), 매도(index == 1)
                let isAsk = index == 0
                
                // MARK: 기준가 레이아웃 설정
                self.amountTextFeild.text = "0"
                
                // MARK: 수량 레이아웃 설정
                let amountTitle: String = isAsk ? "매수 수량" : "매도 수량"
                self.amountLabel.text = amountTitle
                
                self.amountTextFeild.text = "0"
                
                // MARK: 버튼 레이아웃 설정
                let buttonTitle = isAsk ? "매수" : "매도"
                let buttonColor = isAsk ? ThemeColor.risePrimary : ThemeColor.fallPrimary
                
                self.orderButton.setTitle(buttonTitle, for: .normal)
                self.orderButton.backgroundColor = buttonColor
                
            }).disposed(by: disposeBag)
    }
    
    // MARK: 호가창 테이블뷰의 스크롤을 가운데로 정렬
    private func centerTableView() {
        if orderbookUnits.count == 0 { return }
        let middleIndexPath = IndexPath(row: orderbookUnits.count, section: 0)
        self.tableView.scrollToRow(at: middleIndexPath, at: .middle, animated: false)
        self.isAlignCenter = true
    }
}


extension OrderViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // MARK: 호가 정보하나당 매수호가, 매도호가가 존재하기 때문에, item 1개당 로우 2개 배치
        return self.orderbookUnits.count * 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: OrderCell.cellId, for: indexPath) as! OrderCell
        cell.selectionStyle = .none
        
        // MARK: 가져올 인덱스, indexPath.row보다 orderbookUnits.count가 크면 동일 인덱스의 매수호가 사용하고, indexPath.row가 동일할 때 부터 index를 0으로 초기화 하기 위해 호가정보의 갯수를 빼줌
        let index = indexPath.row < orderbookUnits.count ? indexPath.row : indexPath.row - orderbookUnits.count
        
        // MARK: n번째의 호가 정보
        let orderBook = indexPath.row < orderbookUnits.count ? orderbookUnits[orderbookUnits.count - 1 - index] : orderbookUnits[index]
        
        // MARK: index에 따라 매수호가, 매도호가 데이터 사용
        let price = indexPath.row < orderbookUnits.count ? orderBook.ask_price : orderBook.bid_price
        
        // MARK: index에 따라 매수잔량, 매도잔량 데이터 사용
        let size = indexPath.row < orderbookUnits.count ? orderBook.ask_size : orderBook.bid_size
        
        // MARK: 매수, 매도 잔량중 최고치
        let maxSize = orderbookUnits.isEmpty ? 0 : orderbookUnits.max(by: { max($0.ask_size, $0.bid_size) < max($1.ask_size, $1.bid_size) }).map { max($0.ask_size, $0.bid_size) } ?? 0
        
        // MARK: 셀 구성
        cell.configure(price: price, ticker: self.ticker, size: size, maxSize: maxSize, isAsk: indexPath.row < orderbookUnits.count)
        
        // MARK: 실시간 호가 강조 테두리 설정
        if let tradePrice = ticker?.trade_price, tradePrice == price {
            cell.layer.borderWidth = 1.0
            cell.layer.borderColor = ThemeColor.evenPrimary.cgColor
        } else {
            cell.layer.borderWidth = 0.0
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // MARK: 선택된 셀의 인덱스 계산
        let index = indexPath.row < orderbookUnits.count ? indexPath.row : indexPath.row - orderbookUnits.count
        
        // MARK: 선택된 호가 정보 가져오기
        let orderBook = indexPath.row < orderbookUnits.count ? orderbookUnits[orderbookUnits.count - 1 - index] : orderbookUnits[index]
        
        // MARK: 매수 또는 매도 호가에 따라 다른 값 설정
        let price = indexPath.row < orderbookUnits.count ? orderBook.ask_price : orderBook.bid_price
        let size = indexPath.row < orderbookUnits.count ? orderBook.ask_size : orderBook.bid_size
        let isAsk = indexPath.row < orderbookUnits.count // 매수(true)인지 매도(false)인지 확인
        
        // MARK: 선택된 데이터 출력 (또는 원하는 로직 처리)
        print("선택된 값 - Price: \(price), Size: \(size), isAsk: \(isAsk)")
        
        // MARK: 선택된 가격 저장
        self.seletedPrice = price
    }
}
