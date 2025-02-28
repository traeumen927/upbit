//
//  MarketViewController.swift
//  upbit
//
//  Created by 홍정연 on 2/17/25.
//

import UIKit
import RxSwift
import RxCocoa
import Toast

class MarketViewController: UIViewController {
    // MARK: ViewModel
    private let viewModel: MarketViewModel
    
    // MARK: disposeBag
    private let disposeBag = DisposeBag()
    
    // MARK: Diffable Data Source
    private var dataSource: MarketTableDataSource!
    
    // MARK: 테이블뷰
    lazy var marketTableView: UITableView = {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.layout()
        self.bind()
    }
    
    private func layout() {
        self.view.addSubview(self.marketTableView)
        self.marketTableView.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalToSuperview()
        }
    }
    
    private func bind() {
        // MARK: DataSource 연결
        self.dataSource = MarketTableDataSource(tableView: self.marketTableView)
        
        // MARK: 거래 가능한 목록 구독
        self.viewModel.marketTickerSubject
            .observe(on: MainScheduler.instance)
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
    }
}
