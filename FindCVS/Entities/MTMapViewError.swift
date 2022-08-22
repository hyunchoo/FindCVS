//
//  MTMapViewError.swift
//  FindCVS
//
//  Created by 🙈 🙊 on 2022/08/22.
//

import Foundation


enum MTMapViewError: Error {
    case failedUPdatingCurrentLocation
    case locationAuthorizaationDenied
    
    var errorDescription: String {
        switch self {
        case.failedUPdatingCurrentLocation:
            return "현재 위치를 불러오지 못했어요. 잠시후 다시 시도해 주세요."
        case.locationAuthorizaationDenied:
            return "위치 정보를 비활성화하면 사용자의 현재 위치를 알 수 없어요"
        }
    }
}
