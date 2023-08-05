//
//  AddContactURLViewController.swift
//  GAM
//
//  Created by Jungbin on 2023/08/02.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class AddContactURLViewController: BaseViewController {
    
    private enum Text {
        static let placeholder = "포트폴리오 링크를 입력해 주세요."
        static let title = "포트폴리오 링크를 입력해 주세요!"
        static let content = "인스타그램, 비핸스, 노션 등\n나를 더욱 다채롭게 표현해 보아요!"
        static let info = "올바른 링크를 입력해 주세요."
        static let done = "입력 완료"
    }
    
    // MARK: UIComponents
    
    private let navigationView: GamNavigationView = GamNavigationView(type: .back)
    
    private let titleLabel: GamSingleLineLabel = GamSingleLineLabel(text: Text.title, font: .headline2SemiBold)
    
    private let contentLabel: GamSingleLineLabel = GamSingleLineLabel(text: Text.content, font: .caption3Medium)
    
    private let textField: GamTextField = {
        let textField: GamTextField = GamTextField(type: .url)
        textField.placeholder = Text.placeholder
        return textField
    }()
    
    private let infoLabel: GamSingleLineLabel = GamSingleLineLabel(text: Text.info, font: .caption1Regular, color: .gamRed)
    
    private let doneButton: GamFullButton = {
        let button: GamFullButton = GamFullButton(type: .system)
        button.setTitle(Text.done, for: .normal)
        button.isEnabled = false
        return button
    }()
    
    // MARK: Properties
    
    private var contactURLType: ContactURLType = .behance
    private let disposeBag: DisposeBag = DisposeBag()
    private var keyboardHeight: CGFloat = 0
    
    // MARK: Initializer
    
    init(type: ContactURLType, url: String) {
        super.init(nibName: nil, bundle: nil)
        
        self.contactURLType = type
        self.textField.text = url
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUI()
        self.setLayout()
        self.setInfoLabel()
        self.setDoneButtonAction()
        self.setBackButtonAction(self.navigationView.backButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.addKeyboardObserver(willShow: #selector(self.keyboardWillShow(_:)), willHide: #selector(self.keyboardWillHide(_:)))
        self.textField.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.removeKeyboardObserver()
    }
    
    // MARK: Methods
    
    private func setUI() {
        self.contentLabel.numberOfLines = 2
    }
    
    private func setInfoLabel() {
        self.textField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe(onNext: { (owner, changedText) in
                if changedText.count > 0 {
                    let regex = "(https?://)?(www.)?[-a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ@:%._+~#=]{2,256}.[a-z]{2,6}([-a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ@:%_+.~#?&//=]*)"
                    if NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: changedText) && changedText.trimmingCharacters(in: .whitespaces).count >= 1 {
                        self.infoLabel.isHidden = true
                        self.doneButton.isEnabled = true
                    } else {
                        self.infoLabel.isHidden = false
                        self.doneButton.isEnabled = false
                    }
                } else {
                    self.infoLabel.isHidden = true
                    self.doneButton.isEnabled = false
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setDoneButtonAction() {
        self.doneButton.setAction { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc
    func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.keyboardHeight = keyboardRectangle.height
            self.doneButton.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(self.keyboardHeight + 16)
            }
        }
    }
    
    @objc
    func keyboardWillHide(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.keyboardHeight = keyboardRectangle.height
            self.doneButton.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(102.adjustedH)
            }
        }
    }
}

// MARK: - UI

extension AddContactURLViewController {
    private func setLayout() {
        self.view.addSubviews([navigationView, titleLabel, contentLabel, textField, infoLabel, doneButton])
        
        self.navigationView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.navigationView.snp.bottom).offset(32)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        self.contentLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        self.textField.snp.makeConstraints { make in
            make.top.equalTo(self.contentLabel.snp.bottom).offset(60.adjustedH)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        
        self.infoLabel.snp.makeConstraints { make in
            make.top.equalTo(self.textField.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        self.doneButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(102.adjustedH)
            make.height.equalTo(48)
        }
    }
}