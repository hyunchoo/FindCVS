//
//  LocationInformationModel.swift
//  FindCVS
//
//  Created by 🙈 🙊 on 2022/08/22.
//

import Foundation
import RxSwift

struct LocationInformationModel {
    var localNetwork: LocalNetwork
    
    init(localNetwork: LocalNetwork = LocalNetwork()) {
        self.localNetwork = localNetwork
    }
    
    func getLocation(by mapPoint: MTMapPoint) -> Single<Result<LocationData, URLError>> {
        return localNetwork.getLocation(by: mapPoint)
    }
    
    func documnetsToCellData(_ data: [KLDocument]) -> [DetailListCellData] {
        return data.map {
            let address = $0.roadAddressName.isEmpty ? $0.addressName: $0.roadAddressName
            // 만약에 도로면주소가 없으면 그냥 주소라도 줘
            let point = documentToMapPoint($0)
            return DetailListCellData(placeName: $0.placeName, address: $0.addressName, distance: $0.distance, point: point)
        }
    }
    func documentToMapPoint(_ doc: KLDocument) -> MTMapPoint {
        let latitude = Double(doc.x) ?? .zero
        let longitude = Double(doc.y) ?? .zero
        return MTMapPoint(geoCoord: MTMapPointGeo(latitude: latitude, longitude: longitude))
    }
    
    
}
