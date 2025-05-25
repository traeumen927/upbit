//
//  HistoryViewController.swift
//  upbit
//
//  Created by 홍정연 on 5/25/25.
//

import UIKit

class HistoryViewController: UIViewController {
    
    // MARK: ViewModel
    private let viewModel: HistoryViewModel
    
    init(viewModel: HistoryViewModel) {
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
