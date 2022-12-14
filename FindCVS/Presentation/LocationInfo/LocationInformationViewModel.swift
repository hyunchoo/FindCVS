//
//  LocationInformationViewModel.swift
//  FindCVS
//
//  Created by ๐ ๐ on 2022/08/21.
//

import RxSwift
import RxCocoa
import Foundation

struct LocationInformationViewModel {
    let disposeBag = DisposeBag()
    
    //subViewModels
    let detailListBackgroundViewModel = DetailListBackgroundViewModel()
    
    
    //viewModel -> view
    let setMapCenter: Signal<MTMapPoint> // ์ผํฐ๋ฅผ ์ก์ผ๋ผ๋ ์ด๋ฒคํธ
    let errorMessage: Signal<String> // ์ ๋ฌ๋ฉ์ธ์ง๋ฅผ ์ ๋ฌ
    
    let detailListCellData: Driver<[DetailListCellData]>
    //api ํต์ ์ ํตํด ์ ๋ฌํด ํ์ด๋ธ๋ทฐ์ ํํํด์ค๋ค
    let scrollerToSelectedLocation: Signal<Int>
    //ํน์ ์์น๋ฅผ ๋๋ ์๋ ๋๋ ๋ ๊ณณ์ ํ์ํ๋
    
    
    //view -> viewModel
    let currentLocation = PublishRelay<MTMapPoint>()
    let mapCenterPoint = PublishRelay<MTMapPoint>()
    let selectPOIItem = PublishRelay<MTMapPOIItem>()
    let mapViewError = PublishRelay<String>()
    let currentLoacationButtonTapped = PublishRelay<Void>()
    
    let detailListItemSelected = PublishRelay<Int>()
    //๋ฆฌ์คํธ๊ฐ ์ ํ ๋์์๋ ๋ก์ฐ๊ฐ์ ์ ๋ฌํด์ค๋ค
    
   private let documentData = PublishSubject<[KLDocument]>()
    // ์ด๋ฒคํธ๋ฅผ ํตํด์ documentData ๋ฅผ ๋ฐ์ผ๋ฉด KLDocument์ ํํ๋ก ๋ณํํด ๋ฐ๋๋ค
    
    init(model: LocationInformationModel = LocationInformationModel()) {
        //MAKR: /Network ํต์ ์ผ๋ก ๋ฐ์ดํฐ ๋ถ๋ฌ์ค๊ธฐ
        let cvsLocationDataResult = mapCenterPoint
            .flatMapFirst(model.getLocation)
            .share()
        
        let cvsLocationDataValue = cvsLocationDataResult
            .compactMap { data -> LocationData? in
                guard case let .success(value) = data else {
                    return nil
                }
                return value
            }
        
        let cvsLocationDataErrorMessage = cvsLocationDataResult
            .compactMap { data -> String? in
                switch data {
                case let .success(data) where data.documents.isEmpty:
                    return """
                    500m ๊ทผ์ฒ์ ์ด์ฉํ ์์๋ ํธ์์ ์ด ์์ต๋๋ค.
                    ์ง๋ ์์น๋ฅผ ์ฎ๊ฒจ์ ์ฌ๊ฒ์ ํด์ฃผ์ธ์.
                    """
                case let .failure(error):
                    return error.localizedDescription
                default:
                   return nil
                }
            }
        
        cvsLocationDataValue
            .map { $0.documents }
            .bind(to: documentData)
            .disposed(by: disposeBag)
        
            
        
        
        //MAKR: ์ง๋ ์ค์ฌ์  ์ค์ 
        let selectDetailListItem = detailListItemSelected //
            .withLatestFrom(documentData) { $1[$0] }
            .map { data -> MTMapPoint in
                guard  let longtitue = Double(data.x),
                       let latitude = Double(data.y) else {
                          return MTMapPoint()
                      }
                let geoCoord = MTMapPointGeo(latitude: latitude, longitude: longtitue)
                return MTMapPoint(geoCoord: geoCoord)
            }
        
        let moveToCurrentLocation = currentLoacationButtonTapped
            .withLatestFrom(currentLocation)
        
        let currentMapCenter = Observable
            .merge(
                currentLocation.take(1),
                moveToCurrentLocation
            )
        setMapCenter = currentMapCenter
            .asSignal(onErrorSignalWith: .empty())
        
        
        
        errorMessage = Observable
            .merge(
            cvsLocationDataErrorMessage,
            mapViewError.asObservable()
            )
            .asSignal(onErrorJustReturn: "์ ์ ํ ๋ค์ ์๋ํด์ฃผ์ธ์")
        
        detailListCellData = documentData
            .map(model.documnetsToCellData)
            .asDriver(onErrorDriveWith: .empty())
        
        documentData
            .map { !$0.isEmpty }
            .bind(to: detailListBackgroundViewModel.shouldHideStatusLabel)
            .disposed(by: disposeBag)
        
        scrollerToSelectedLocation = selectPOIItem
            .map { $0.tag }
            .asSignal(onErrorJustReturn: 0)
    }
}
