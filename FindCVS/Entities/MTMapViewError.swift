//
//  MTMapViewError.swift
//  FindCVS
//
//  Created by π π on 2022/08/22.
//

import Foundation


enum MTMapViewError: Error {
    case failedUPdatingCurrentLocation
    case locationAuthorizaationDenied
    
    var errorDescription: String {
        switch self {
        case.failedUPdatingCurrentLocation:
            return "νμ¬ μμΉλ₯Ό λΆλ¬μ€μ§ λͺ»νμ΄μ. μ μν λ€μ μλν΄ μ£ΌμΈμ."
        case.locationAuthorizaationDenied:
            return "μμΉ μ λ³΄λ₯Ό λΉνμ±ννλ©΄ μ¬μ©μμ νμ¬ μμΉλ₯Ό μ μ μμ΄μ"
        }
    }
}
