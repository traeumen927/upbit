//
//  OrderBookViewController.swift
//  upbit
//
//  Created by 홍정연 on 4/10/25.
//

import UIKit

class OrderBookViewController: UIViewController {
    
    // MARK: ViewModel
    private let viewModel: OrderBookViewModel
    
    init(viewModel: OrderBookViewModel) {
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
