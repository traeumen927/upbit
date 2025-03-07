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
    
}
