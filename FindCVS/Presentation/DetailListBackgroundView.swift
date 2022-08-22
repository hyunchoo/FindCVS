//
//  DetailListBackgroundView.swift
//  FindCVS
//
//  Created by 🙈 🙊 on 2022/08/22.
//

import RxSwift
import RxCocoa

class DetailListBackgroundView: UIView {
    let disposeBage = DisposeBag()
    let statusLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(_ viewMdoel: DetailListBackgroundViewModel) {
        viewMdoel.isStatusLabelHidden
            .emit(to: statusLabel.rx.isHidden)
            .disposed(by: disposeBage)
    }
    
    private func attribute() {
        backgroundColor = .white
        statusLabel.text = "🏪"
        statusLabel.textAlignment = .center
    }
    
    private func layout() {
        addSubview(statusLabel)
        
        statusLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
}
