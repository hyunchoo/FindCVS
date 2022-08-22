//
//  LocationInformationViewModel.swift
//  FindCVS
//
//  Created by 🙈 🙊 on 2022/08/21.
//

import RxSwift
import RxCocoa
import Foundation

struct LocationInformationViewModel {
    let disposeBag = DisposeBag()
    
    //subViewModels
    let detailListBackgroundViewModel = DetailListBackgroundViewModel()
    
    
    //viewModel -> view
    let setMapCenter: Signal<MTMapPoint> // 센터를 잡으라는 이벤트
    let errorMessage: Signal<String> // 애러메세지를 전달
    
    let detailListCellData: Driver<[DetailListCellData]>
    //api 통신을 통해 전달해 테이블뷰에 표현해준다
    let scrollerToSelectedLocation: Signal<Int>
    //특정위치를 눌렀을때 눌렀던 곳을 표시하는
    
    
    //view -> viewModel
    let currentLocation = PublishRelay<MTMapPoint>()
    let mapCenterPoint = PublishRelay<MTMapPoint>()
    let selectPOIItem = PublishRelay<MTMapPOIItem>()
    let mapViewError = PublishRelay<String>()
    let currentLoacationButtonTapped = PublishRelay<Void>()
    
    let detailListItemSelected = PublishRelay<Int>()
    //리스트가 선택 되엇을떄 로우값을 전달해준다
    
   private let documentData = PublishSubject<[KLDocument]>()
    // 이벤트를 통해서 documentData 를 받으면 KLDocument의 형태로 변환해 받는다
    
    init(model: LocationInformationModel = LocationInformationModel()) {
        //MAKR: /Network 통신으로 데이터 불러오기
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
                    500m 근처에 이용할수있는 편의점이 없습니다.
                    지도 위치를 옮겨서 재검색 해주세요.
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
        
            
        
        
        //MAKR: 지도 중심점 설정
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
            .asSignal(onErrorJustReturn: "잠시 후 다시 시도해주세요")
        
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
