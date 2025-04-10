//
//  ChatViewController.swift
//  upbit
//
//  Created by 홍정연 on 4/10/25.
//

import UIKit

class ChatViewController: UIViewController {
    
    // MARK: ViewModel
    private let viewModel: ChatViewModel
    
    init(viewModel: ChatViewModel) {
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
