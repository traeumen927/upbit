//
//  BorderedTextField.swift
//  upbit
//
//  Created by 홍정연 on 5/16/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class BorderedTextField: UIView {
    
    // MARK: 내부 텍스트 필드
    fileprivate let textField: UITextField = UITextField()
    
    /// 외부에서 텍스트 필드의 값을 읽거나 설정할 수 있는 computed property
    var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }
    
    /// 정렬
    var alignment: NSTextAlignment = .left {
        didSet {
            textField.textAlignment = alignment
        }
    }
    
    /// 키보드타입
    var keyboardType: UIKeyboardType = .default {
        didSet {
            textField.keyboardType = keyboardType
        }
    }
    
    /// 유저 상호작용 여부
    var isInteractionEnabled: Bool = true {
        didSet {
            textField.isUserInteractionEnabled = isInteractionEnabled
            self.isUserInteractionEnabled = isInteractionEnabled
        }
    }
    
    
    
    /// Return key type을 설정하기 위한 프로퍼티
    var returnKeyType: UIReturnKeyType = .default {
        didSet {
            textField.returnKeyType = returnKeyType
        }
    }
    
    /// 플레이스홀더 텍스트
    var placeholder: String? {
        didSet { updatePlaceholder() }
    }
    
    /// 플레이스홀더 색상
    var placeholderColor: UIColor = ThemeColor.tintDisable {
        didSet { updatePlaceholder() }
    }
    
    /// 테두리 두께 (기본: 1.0)
    var borderWidth: CGFloat = 1.0 {
        didSet { layer.borderWidth = borderWidth }
    }
    
    /// 폰트
    var font: UIFont = UIFont.systemFont(ofSize: 14, weight: .regular) {
        didSet { textField.font = font }
    }
    
    /// 활성화 폰트 색상
    var normalFontColor: UIColor = ThemeColor.label1 {
        didSet {
            if isEnabled {
                textField.textColor = normalFontColor
            }
        }
    }
    
    /// 비활성화 폰트 색상
    var disabledFontColor: UIColor = ThemeColor.label3 {
        didSet {
            if !isEnabled {
                textField.textColor = disabledFontColor
            }
        }
    }
    
    
    // 평상시 상태 (활성화되고 편집중이 아닐 때)
    var normalBackgroundColor: UIColor = .white {
        didSet { if isEnabled && !isEditing { self.backgroundColor = normalBackgroundColor } }
    }
    var normalBorderColor: UIColor = ThemeColor.background3 {
        didSet { if isEnabled && !isEditing { layer.borderColor = normalBorderColor.cgColor } }
    }
    
    // 선택(편집중) 상태
    var selectedBackgroundColor: UIColor = .white {
        didSet { if isEditing { self.backgroundColor = selectedBackgroundColor } }
    }
    var selectedBorderColor: UIColor = ThemeColor.background3 {
        didSet { if isEditing { layer.borderColor = selectedBorderColor.cgColor } }
    }
    
    // 비활성화 상태
    var disabledBackgroundColor: UIColor = ThemeColor.background3 {
        didSet { if !isEnabled { self.backgroundColor = disabledBackgroundColor } }
    }
    var disabledBorderColor: UIColor = ThemeColor.tintDisable {
        didSet { if !isEnabled { layer.borderColor = disabledBorderColor.cgColor } }
    }
    
    // MARK: - 내부 상태 변수
    
    /// 현재 편집중 여부
    private var isEditing: Bool = false
    
    /// 커스텀 활성/비활성 상태
    var isEnabled: Bool = true {
        didSet {
            textField.isUserInteractionEnabled = isEnabled
            updateAppearanceForCurrentState()
        }
    }
    
    // MARK: - 초기화
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    
    private func commonInit() {
        // 기본 설정
        layer.borderWidth = borderWidth
        layer.cornerRadius = 8
        layer.masksToBounds = true
        backgroundColor = normalBackgroundColor
        layer.borderColor = normalBorderColor.cgColor
        
        // 텍스트필드 추가 및 레이아웃 설정 (SnapKit 사용)
        addSubview(textField)
        textField.snp.makeConstraints { make in
            // 내부 여백 12 포인트
            make.edges.equalToSuperview().inset(12)
        }
        
        // 텍스트필드 기본 설정
        textField.font = font
        
        // 초기 활성 상태 폰트 색상 적용
        textField.textColor = normalFontColor
        
        // 편집 시작/종료 이벤트를 통해 상태 업데이트
        textField.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
    }
    
    // MARK: - 상태에 따른 외관 업데이트
    private func updateAppearanceForCurrentState() {
        if !isEnabled {
            backgroundColor = disabledBackgroundColor
            layer.borderColor = disabledBorderColor.cgColor
            textField.textColor = disabledFontColor
        } else if isEditing {
            backgroundColor = selectedBackgroundColor
            layer.borderColor = selectedBorderColor.cgColor
            // 편집 중에는 활성 상태 폰트 색상 유지
            textField.textColor = normalFontColor
        } else {
            backgroundColor = normalBackgroundColor
            layer.borderColor = normalBorderColor.cgColor
            textField.textColor = normalFontColor
        }
    }
    
    // MARK: - 플레이스홀더 업데이트
    private func updatePlaceholder() {
        guard let placeholder = placeholder else {
            textField.attributedPlaceholder = nil
            return
        }
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: placeholderColor]
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
    }
    
    // MARK: - 편집 이벤트 핸들러
    @objc private func editingDidBegin() {
        isEditing = true
        updateAppearanceForCurrentState()
    }
    
    @objc private func editingDidEnd() {
        isEditing = false
        updateAppearanceForCurrentState()
    }
}

// MARK: 외부에서 Rx로 접근하기 위한 extension
extension Reactive where Base: BorderedTextField {
    var text: ControlProperty<String?> {
        return base.textField.rx.text
    }
    
    var editingDidEndOnExit: ControlEvent<Void> {
        return base.textField.rx.controlEvent(.editingDidEndOnExit)
    }
}

