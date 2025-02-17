//
//  MarketViewController.swift
//  upbit
//
//  Created by 홍정연 on 2/17/25.
//

import UIKit

class MarketViewController: UIViewController {
    // MARK: ViewModel
    private let viewModel: MarketViewModel
    
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
    }
    
    private func layout() {
        
    }
}
