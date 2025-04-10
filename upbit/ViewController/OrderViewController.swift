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
    
    private lazy var tableView: UITableView = {
        let tableview = UITableView()
        tableview.register(OrderCell.self, forCellReuseIdentifier: OrderCell.cellId)
        tableview.backgroundColor = .clear
        tableview.showsVerticalScrollIndicator = true
        tableview.separatorStyle = .none
        return tableview
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
        self.view.addSubview(self.tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.4)
        }
    }
    
    private func bind() {
        // MARK: 호가 구독
        self.viewModel.orderbookObservable
            .subscribe(onNext: { [weak self] orderbook in
                guard let self = self else { return }
            }).disposed(by: disposeBag)
    }
}

