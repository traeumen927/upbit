//
//  BorderedTextView.swift
//  upbit
//
//  Created by 홍정연 on 5/16/25.
//

import UIKit
import SnapKit

class BorderedTextView: UIView {
    
    // MARK: 내부 텍스트뷰
    private let textView: UITextView = UITextView()
    
    // MARK: Placeholder용 라벨
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeColor.tintDisable  // 기본 placeholder 색상
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    /// 외부에서 텍스트 필드의 값을 읽거나 설정할 수 있는 computed property
    var text: String? {
        get {
            return textView.text
        }
        set {
            textView.text = newValue
            updatePlaceholderVisibility()
            invalidateIntrinsicContentSize()
        }
    }
    
    // MARK: - 커스터마이징 가능한 프로퍼티
    var font: UIFont = UIFont.systemFont(ofSize: 14, weight: .regular) {
        didSet {
            textView.font = font
            invalidateIntrinsicContentSize()
        }
    }
    var fontColor: UIColor = ThemeColor.label1 {
        didSet { textView.textColor = fontColor }
    }
    
    /// placeholder 텍스트
    var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
            updatePlaceholderVisibility()
        }
    }
    
    /// placeholder 색상
    var placeholderColor: UIColor = ThemeColor.tintDisable {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }
    
    // 평상시 상태 (활성화되고 편집중이 아닐 때)
    var normalBackgroundColor: UIColor = .white {
        didSet { if isEnabled && !isEditing { backgroundColor = normalBackgroundColor } }
    }
    var normalBorderColor: UIColor = ThemeColor.background3 {
        didSet { if isEnabled && !isEditing { layer.borderColor = normalBorderColor.cgColor } }
    }
    
    // 선택(편집중) 상태
    var selectedBackgroundColor: UIColor = .white {
        didSet { if isEditing { backgroundColor = selectedBackgroundColor } }
    }
    var selectedBorderColor: UIColor = ThemeColor.background3 {
        didSet { if isEditing { layer.borderColor = selectedBorderColor.cgColor } }
    }
    
    // 비활성화 상태
    var disabledBackgroundColor: UIColor = ThemeColor.background3 {
        didSet { if !isEnabled { backgroundColor = disabledBackgroundColor } }
    }
    var disabledBorderColor: UIColor = ThemeColor.tintDisable {
        didSet { if !isEnabled { layer.borderColor = disabledBorderColor.cgColor } }
    }
    
    // MARK: - 내부 상태 변수
    private var isEditing: Bool = false
    
    /// 커스텀 활성/비활성 상태 (UIView에는 isEnabled가 없으므로 직접 관리)
    var isEnabled: Bool = true {
        didSet {
            textView.isUserInteractionEnabled = isEnabled
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
        // 기본 외관 설정
        layer.borderWidth = 1.0
        layer.cornerRadius = 8
        layer.masksToBounds = true
        backgroundColor = normalBackgroundColor
        layer.borderColor = normalBorderColor.cgColor
        
        // 텍스트뷰 추가 및 레이아웃 설정 (SnapKit 사용)
        addSubview(textView)
        textView.snp.makeConstraints { make in
            // 내부 여백 12 포인트
            make.edges.equalToSuperview().inset(12)
        }
        
        // 텍스트뷰 기본 설정
        textView.font = font
        textView.textColor = fontColor
        textView.backgroundColor = .clear
        // 텍스트뷰의 내부 여백 (원하는 값으로 조정)
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        
        // **중요:** 텍스트뷰가 스크롤되지 않고 내용에 맞게 확장되도록 설정
        textView.isScrollEnabled = false
        
        // placeholderLabel 추가 (텍스트뷰 위에 위치)
        addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { make in
            // 텍스트뷰와 동일한 inset 적용
            make.top.equalTo(textView.snp.top)
            make.leading.equalTo(textView.snp.leading)
            make.trailing.equalTo(textView.snp.trailing)
        }
        
        // 초기 placeholder 표시
        placeholderLabel.text = placeholder
        updatePlaceholderVisibility()
        
        
        // 편집 이벤트를 위해 delegate 설정
        textView.delegate = self
    }
    
    // MARK: - 상태에 따른 외관 업데이트
    private func updateAppearanceForCurrentState() {
        if !isEnabled {
            backgroundColor = disabledBackgroundColor
            layer.borderColor = disabledBorderColor.cgColor
        } else if isEditing {
            backgroundColor = selectedBackgroundColor
            layer.borderColor = selectedBorderColor.cgColor
        } else {
            backgroundColor = normalBackgroundColor
            layer.borderColor = normalBorderColor.cgColor
        }
    }
    
    // MARK: - Placeholder Visibility 업데이트
    private func updatePlaceholderVisibility() {
        // 텍스트가 비어 있으면 placeholder 보여주고, 그렇지 않으면 숨김
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    // MARK: - Intrinsic Content Size
    /// 내용에 따라 적절한 높이를 반환하도록 오버라이드.
    /// 최소 높이는 한 줄(텍스트 필드처럼) 높이를 유지합니다.
    override var intrinsicContentSize: CGSize {
        // 계산할 때, 텍스트뷰 내부 여백을 고려합니다.
        let horizontalInsets = textView.textContainerInset.left + textView.textContainerInset.right
        let availableWidth = bounds.width - horizontalInsets
        // sizeThatFits를 사용하여 텍스트뷰의 적절한 사이즈 계산
        let textSize = textView.sizeThatFits(CGSize(width: availableWidth, height: CGFloat.greatestFiniteMagnitude))
        // 상하 여백도 고려 (top + bottom)
        let verticalInsets = textView.textContainerInset.top + textView.textContainerInset.bottom
        let height = max(textSize.height, font.lineHeight + verticalInsets)
        return CGSize(width: UIView.noIntrinsicMetric, height: height + 24) // 추가 여유분 (예: 24 포인트)를 더할 수 있습니다.
    }
    
    // 호출 시마다 layout 갱신 (필요하다면)
    func updateContentSize() {
        invalidateIntrinsicContentSize()
    }
}

// MARK: - UITextViewDelegate
extension BorderedTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // 텍스트 변경 시, intrinsicContentSize 재계산
        self.updatePlaceholderVisibility()
        self.invalidateIntrinsicContentSize()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        isEditing = true
        self.updateAppearanceForCurrentState()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        isEditing = false
        self.updateAppearanceForCurrentState()
    }
}

