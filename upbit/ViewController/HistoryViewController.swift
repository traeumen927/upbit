//
//  HistoryViewController.swift
//  upbit
//
//  Created by 홍정연 on 5/25/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class HistoryViewController: UIViewController {

    // MARK: ViewModel
    private let viewModel: HistoryViewModel
    private let disposeBag = DisposeBag()

    private enum Section { case main }

    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["미체결", "체결"])
        control.selectedSegmentIndex = 0
        return control
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.cellId)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "표시할 주문 내역이 없습니다."
        label.textAlignment = .center
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private lazy var dataSource = UITableViewDiffableDataSource<Section, MyOrder>(tableView: tableView) { [weak self] tableView, indexPath, order in
        let cell = tableView.dequeueReusableCell(withIdentifier: HistoryCell.cellId, for: indexPath) as! HistoryCell
        let showCancel = self?.segmentedControl.selectedSegmentIndex == 0
        cell.bind(order: order, showCancel: showCancel ?? false)
        if let self = self {
            cell.cancelButton.rx.tap
                .map { order.uuid }
                .bind(to: self.viewModel.cancelSubject)
                .disposed(by: cell.disposeBag)
        }
        return cell
    }

    init(viewModel: HistoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        bind()
    }

    private func layout() {
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)

        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }

        emptyLabel.snp.makeConstraints { make in
            make.centerY.equalTo(tableView.snp.centerY)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }

    private func bind() {
        let orders = segmentedControl.rx.selectedSegmentIndex
            .startWith(0)
            .flatMapLatest { [weak self] index -> Observable<[MyOrder]> in
                guard let self = self else { return .empty() }
                return index == 0 ? self.viewModel.pendingOrdersRelay.asObservable() : self.viewModel.filledOrdersRelay.asObservable()
            }
            .share(replay: 1)

        orders
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] items in
                var snapshot = NSDiffableDataSourceSnapshot<Section, MyOrder>()
                snapshot.appendSections([.main])
                snapshot.appendItems(items)
                self?.dataSource.apply(snapshot, animatingDifferences: true)
            })
            .disposed(by: disposeBag)

        orders
            .map { !$0.isEmpty }
            .bind(to: emptyLabel.rx.isHidden)
            .disposed(by: disposeBag)
    }
}

