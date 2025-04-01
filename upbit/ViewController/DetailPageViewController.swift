//
//  DetailPageViewController.swift
//  upbit
//
//  Created by 홍정연 on 4/1/25.
//

import UIKit
import RxSwift
import SnapKit
import DGCharts

class DetailPageViewController: UIViewController {
    
    // MARK: ViewModel
    private let viewModel: DetailPageViewModel
    
    // MARK: disposeBag
    private let disposeBag = DisposeBag()
    
    // MARK: 코디네이터 참조
    weak var coordinator: DetailPageViewCoordinator?
    
    init(viewModel: DetailPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.layout()
    }
    
    private func layout() {
        self.view.backgroundColor = .black
    }
}
