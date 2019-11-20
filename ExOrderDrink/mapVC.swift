//
//  mapVC.swift
//  ExOrderDrink
//
//  Created by 張哲禎 on 2019/11/19.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit
import MapKit

class mapVC: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var ann_shopLoaction = MKPointAnnotation()
//    var userLocation = MKUserLocation()
    let shopLocation = CLLocationCoordinate2D(latitude: 24.940222, longitude: 121.214548)//店家位置
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.requestWhenInUseAuthorization()//要用到user的位置
        setMapRegion()//只show某一塊地圖
        showLocation()
    }
    @IBAction func btBack(_ sender: Any) {
        setMapRegion()
        showLocation()
    }
    @IBAction func btGo(_ sender: Any) {
        locationManager.delegate = self  //委派給ViewController
        mapView.delegate = self
        mapView.userTrackingMode = .follow  //隨著user移動
        mapView.showsUserLocation = true//顯示user的位置點
        locationManager.startUpdatingLocation()  //開始update user位置
        direct(start: self.mapView.userLocation.coordinate, end: self.shopLocation)
//        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (time) in
//            print(self.mapView.userLocation.coordinate)
//            self.direct(start: self.mapView.userLocation.coordinate, end: self.shopLocation)
//        }
//        print(mapView.userLocation.coordinate)
//        direct(start: mapView.userLocation.coordinate, end: shopLocation)
    }
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//        mapView.setCenter(userLocation.coordinate, animated: true)
    }
    
    func setMapRegion() {
//       緯度1度時的經度1度約111公里,越靠近南北極,經度線越短
//        這邊設定顯示範圍為經緯度各2度
        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        var region = MKCoordinateRegion()
        region.span = span//設定region的範圍
        mapView.setRegion(region, animated: true)
        mapView.regionThatFits(region)//調整指定區域的縱橫比，以確保其適合地圖視圖的框架。
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier:identifier) as? MKPinAnnotationView
        if annotationView == nil { //如果沒有原本標籤的話,就直接生成設定的圖釘標籤
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        annotationView?.animatesDrop = true //圖釘掉落的動畫
        /* annotationView可以設定點擊圖針時是否跳出對話框 */
        annotationView?.canShowCallout = true
        return annotationView
    }
    func showLocation(){
        ann_shopLoaction.coordinate = shopLocation
        ann_shopLoaction.title = "店家位置"
        ann_shopLoaction.subtitle = "其實是乙男家"
        var annList = [MKPointAnnotation]()
        annList.append(ann_shopLoaction)
        mapView.addAnnotations(annList)
        mapView.showAnnotations(annList, animated: true)
    }
    
    func direct(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) {
        let placemark_start = MKPlacemark(coordinate: start, addressDictionary: nil)
        let placemark_end = MKPlacemark(coordinate: end, addressDictionary: nil)
        let mapItem_start = MKMapItem(placemark: placemark_start)
        let mapItem_end = MKMapItem(placemark: placemark_end)
        
        mapItem_start.name = "現在位置"//導航要給起點名字
        let name = String(format: "(%.4f, %.4f)", end.latitude, end.longitude)
        mapItem_end.name = name   //給導航終點名字
        //        導航未支援多點,傳很多點也是導航兩點
        let mapItems = [mapItem_start, mapItem_end]
        /* 設定導航模式：開車、走路、搭車 */
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        MKMapItem.openMaps(with: mapItems, launchOptions: options)
        //        openMaps開啟手機內建的apleMaps,launchOptions會開啟新的一頁
    }
    
}
