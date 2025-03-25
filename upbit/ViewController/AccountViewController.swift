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
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = "0원"
        return label
    }()
    
    // MARK: 손익금액 라벨
    private lazy var changeLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeColor.evenPrimary
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.text = "0%"
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
    
    // MARK: 데이터 업데이트
    func update() {
        
    }
}
