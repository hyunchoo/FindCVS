//
//  DetailListBackgroundViewModel.swift
//  FindCVS
//
//  Created by π π on 2022/08/22.
//

import RxSwift
import RxCocoa

struct DetailListBackgroundViewModel {
    // viewModel -> view
    let isStatusLabelHidden: Signal<Bool>
        //μΈλΆμμ μ λ¬ λ°μ κ°
    let shouldHideStatusLabel = PublishSubject<Bool>()
    
    init() {
        isStatusLabelHidden = shouldHideStatusLabel
            .asSignal(onErrorJustReturn: true)
    }
}
