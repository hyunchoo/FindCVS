//
//  LocationInformationViewController.swift
//  FindCVS
//
//  Created by π π on 2022/08/21.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa
import SnapKit

class LocationInformationViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    let locationManager = CLLocationManager()
    let mapView = MTMapView()
    let currentLoacationButton = UIButton()
    let detailList = UITableView()
    let detailLsitBackgroundView = DetailListBackgroundView()
    let viewModel = LocationInformationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        
        bind(viewModel)
        attribute()
        layout()
    }
    
    private func bind(_ viewModel: LocationInformationViewModel) {
        detailLsitBackgroundView.bind(viewModel.detailListBackgroundViewModel)
        
        
        //λ§΅λ·°μ μΌν°κ°μΌλ‘ μ΄λν΄λΌ
        viewModel.setMapCenter
            .emit(to: mapView.rx.setMapCenterPoint)
            .disposed(by: disposeBag)

        viewModel.errorMessage
            .emit(to: self.rx.presentAlert)
            .disposed(by: disposeBag)
        
        viewModel.detailListCellData
            .drive(detailList.rx.items) { tv, row, data in
                let cell = tv.dequeueReusableCell(withIdentifier: "DetailListCell", for: IndexPath(row: row, section: 0)) as! DetailListCell
                
                cell.setData(data)
                return cell
            }
            .disposed(by: disposeBag)
        
        viewModel.detailListCellData
            .map {$0.compactMap { $0.point } }
            .drive(self.rx.addPOIItems)
            .disposed(by: disposeBag)
        
        viewModel.scrollerToSelectedLocation
            .emit(to: self.rx.showSelectedLocation)
            .disposed(by: disposeBag)
        
        detailList.rx.itemSelected
            .map { $0.row }
            .bind(to: viewModel.detailListItemSelected)
            .disposed(by: disposeBag)
        
        currentLoacationButton.rx.tap
            .bind(to: viewModel.currentLoacationButtonTapped)
            .disposed(by: disposeBag)
    }
    
    private func attribute() {
        title = "λ΄ μ£Όλ³ νΈμμ  μ°ΎκΈ°"
        view.backgroundColor = .white
        
        mapView.currentLocationTrackingMode = .onWithoutHeadingWithoutMapMoving
        currentLoacationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        currentLoacationButton.backgroundColor = .white
        currentLoacationButton.layer.cornerRadius = 20
        
        detailList.register(DetailListCell.self, forCellReuseIdentifier: "DetailListCell")
        detailList.separatorStyle = .none
        detailList.backgroundView = detailLsitBackgroundView
    }
    
    private func layout() {
        [mapView, currentLoacationButton, detailList].forEach { view.addSubview($0) }
        mapView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.snp.centerY).offset(100)
            
        }
        
        currentLoacationButton.snp.makeConstraints {
            $0.bottom.equalTo(detailList.snp.top).offset(-12)
            $0.leading.equalToSuperview().offset(12)
            $0.width.height.equalTo(40)
            
        }
        
        detailList.snp.makeConstraints {
            $0.centerX.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
            $0.top.equalTo(mapView.snp.bottom)
        }
    }
}


extension LocationInformationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            //μΈμ λ νμ© , μ¬μ©ν λλ§, κ·Έλ₯ λλκΈ°
            case .authorizedAlways,
                 .authorizedWhenInUse,
                 .notDetermined:
                return
            default:
            viewModel.mapViewError.accept(MTMapViewError.locationAuthorizaationDenied.errorDescription)
            return
           
        }
    }
}


extension LocationInformationViewController: MTMapViewDelegate {
    // μλ?¬λ μ΄ν°μμ μ¬μ© λΆκ°λ₯
    func mapView(_ mapView: MTMapView!, updateCurrentLocation location: MTMapPoint!, withAccuracy accuracy: MTMapLocationAccuracy) {
        #if DEBUG
        viewModel.currentLocation.accept(MTMapPoint(geoCoord: MTMapPointGeo(latitude: 37.39422, longitude: 127.1103412)))
        #else
        viewModel.currentLocation.accept(location)
        #endif
    }
    // λ§΅μ μ΄λμ΄ λλ¬μλ λ§μ§λ§ μΌν° ν¬μΈνΈ μ λ¬ν΄μ£Όλκ²
    func mapView(_ mapView: MTMapView!, finishedMapMoveAnimation mapCenterPoint: MTMapPoint!) {
        viewModel.mapCenterPoint.accept(mapCenterPoint)
    }
    // ννμ μμ΄ν¬μ ν­ν λ λ§λ€ λ°μ΄ν° μ λ¬
    func mapView(_ mapView: MTMapView!, selectedPOIItem poiItem: MTMapPOIItem!) -> Bool {
        viewModel.selectPOIItem.accept(poiItem)
        return false
    }
    //νμ¬μμΉλ₯Ό λΆλ¬μ€μ§ λͺ»ν λ μ λ¬λ₯Ό ννν΄μ€λ€
    func mapView(_ mapView: MTMapView!, failedUpdatingCurrentLocationWithError error: Error!) {
        viewModel.mapViewError.accept(error.localizedDescription)
    }
}



extension Reactive where Base: MTMapView {
    var setMapCenterPoint: Binder<MTMapPoint> {
        return Binder(base) { base, point in
            base.setMapCenter(point, animated: true)
            
        }
    }
}

extension Reactive where Base: LocationInformationViewController {
    var presentAlert: Binder<String> {
        return Binder(base) { base, message in
            let alertController = UIAlertController(title: "λ¬Έμ κ° λ°μλ¬μ΅λλ€.", message: message, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "νμΈ", style: .default, handler: nil)
            alertController.addAction(action)
            base.present(alertController, animated: true, completion: nil)
        }
    }
    var showSelectedLocation: Binder<Int> {
        return Binder(base) { base, row in
            let indexPath = IndexPath(row: row, section: 0)
            base.detailList.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        }
    }
    var addPOIItems: Binder<[MTMapPoint]> {
        return Binder(base) { base, points in
            let items = points
                .enumerated()
                .map { offset, point -> MTMapPOIItem in
                    let mapPOIitem = MTMapPOIItem()
                    
                    mapPOIitem.mapPoint = point  // μ§λμ μ’ν
                    mapPOIitem.markerType = .redPin // λ§μ»€ νμ
                    mapPOIitem.showAnimationType = .springFromGround
                    mapPOIitem.tag = offset
                    
                    return mapPOIitem
                }
            base.mapView.removeAllPOIItems() // μλ‘μ΄ κ±Έ κ°μ§λλ§λ€ κ°μ§κ³ μλκ±Έ μ λΆ μ§μμ€λ€
            base.mapView.addPOIItems(items) // μλ‘μ΄κ±Έ κ°μ§κ²λλ©΄ μΆκ°ν΄μ€λ€
        }
    }
}



