//
//  MarketViewController.swift
//  upbit
//
//  Created by 홍정연 on 2/17/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Toast

class MarketViewController: UIViewController {
    // MARK: ViewModel
    private let viewModel: MarketViewModel
    
    // MARK: disposeBag
    private let disposeBag = DisposeBag()
    
    // MARK: 코디네이터 참조
    weak var coordinator: MarketCoordinator?
    
    // MARK: Diffable Data Source
    private var dataSource: MarketTableDataSource!
    
    // MARK: 검색창 영역뷰의 하단 제약 저장 (키보드 대응)
    private var searchViewBottomConstraint: Constraint?
    
    // MARK: 검색창
    private lazy var searchBar: UISearchBar = {
      let view = UISearchBar()
        view.placeholder = "코인명을 검색해주세요."
        view.showsCancelButton = true
        view.searchTextField.textColor = ThemeColor.label1
        view.searchTextField.backgroundColor = ThemeColor.background1
        view.returnKeyType = .search
        return view
    }()
    
    // MARK: 테이블뷰
    private lazy var marketTableView: UITableView = {
        let view = UITableView()
        view.register(MarketCell.self, forCellReuseIdentifier: MarketCell.cellId)
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = true
        view.separatorStyle = .none
        return view
    }()
    
    init(viewModel: MarketViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        // MARK: KeyboardAdjustable 프로토콜의 키보드 옵져버 제거
        self.removeKeyboardObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.layout()
        self.bind()
    }
    
    // MARK: 레이아웃 설정
    private func layout() {
        self.title = "거래소"
        
        // MARK: 우측 상단 BarbuttonItem 정렬 기능 설정
        self.configureSortMenu()
        
        // MARK: 검색창 레이아웃
        self.navigationItem.titleView = self.searchBar
        
        // MARK: 테이블뷰 레이아웃
        self.view.addSubview(self.marketTableView)
        self.marketTableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            self.searchViewBottomConstraint = make.bottom.equalToSuperview().constraint
        }
    }
    
    // MARK: 바인딩 설정
    private func bind() {
        // MARK: KeyboardAdjustable 프로토콜의 옵저버 추가
        self.addKeyboardObservers()
        
        // MARK: DataSource 연결
        self.dataSource = MarketTableDataSource(tableView: self.marketTableView)
        
        // MARK: UISearchBar의 검색어 변경 이벤트 감지
        self.searchBar.rx.text.orEmpty
            .distinctUntilChanged()
            .asObservable()
            .subscribe(onNext: {[weak self] query in
                guard let self = self else { return }
                self.viewModel.searchQuerySubject.onNext(query)
            }).disposed(by: disposeBag)
        
        
        // MARK: UISearchBar의 취소 버튼 이벤트 감지
        self.searchBar.rx.cancelButtonClicked
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.navigationController?.view.endEditing(true)
            }).disposed(by: disposeBag)
        
        // MARK: 거래 가능한 목록 구독, 0.25초 마다 이벤트 방출
        self.viewModel.marketTickerSubject
            .observe(on: MainScheduler.instance)
            .throttle(.milliseconds(250), latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] marketTickers in
                guard let self = self else { return }
                // MARK: snapshot 업데이트
                self.dataSource.update(with: marketTickers)
            }).disposed(by: disposeBag)
        
        // MARK: 메세지 구독
        self.viewModel.messageSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                self.view.makeToast(message, duration: 2.0, position: .bottom)
            }).disposed(by: disposeBag)
        
        // MARK: 셀 선택 이벤트
        self.marketTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self,
                      let marketTicker = self.dataSource.itemIdentifier(for: indexPath)
                else { return }
                // MARK: 디테일 페이지 이동
                self.coordinator?.showDetail(marketInfo: marketTicker.marketInfo)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: 코인 정렬메뉴 설정
    private func configureSortMenu() {
        // MARK: sort 옵션별 액션 할당
        let actions = SortOption.allCases.map { option -> UIAction in
            let state: UIMenuElement.State = (option == self.viewModel.sortOption) ? .on : .off
            return UIAction(title: option.rawValue, state: state) { [weak self] _ in
                guard let self = self else { return }
                
                // MARK: viewModel에 변경된 정렬 option 전달
                self.viewModel.sortOption = option
                
                // MARK: 메뉴의 상태를 갱신
                self.configureSortMenu()
            }
        }
        
        let menu = UIMenu(title: "정렬 옵션", children: actions)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"), menu: menu)
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

// MARK: - Place for extension with KeyboardAdjustable
extension MarketViewController: KeyboardAdjustable {
    var adjustableBottomConstraint: Constraint? {
        get { return self.searchViewBottomConstraint }
        set { self.searchViewBottomConstraint = newValue }
    }
}
