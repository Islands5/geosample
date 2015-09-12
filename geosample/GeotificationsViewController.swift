//
//  GeotificationsViewController.swift
//  geosample
//
//  Created by 五島　僚太郎 on 2015/09/12.
//  Copyright (c) 2015年 rg. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class GeotificationsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    var myMapView: MKMapView!
    var myLocationManager: CLLocationManager!
    
    // 縮尺.
    let myLatDist : CLLocationDistance = 1000
    let myLonDist : CLLocationDistance = 1000
    
    //皇居
    let targetLocation: CLLocation = CLLocation(latitude: 35.685175, longitude: 139.7528)
    let pinDistance = CLLocationDistance(900)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // LocationManagerの生成.
        myLocationManager = CLLocationManager()
        
        // Delegateの設定.
        myLocationManager.delegate = self
        
        // 距離のフィルタ.
        myLocationManager.distanceFilter = 100.0
        
        // 精度.
        myLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        // セキュリティ認証のステータスを取得.
        let status = CLLocationManager.authorizationStatus()
        
        // まだ認証が得られていない場合は、認証ダイアログを表示.
        if(status == CLAuthorizationStatus.NotDetermined) {
            
            // まだ承認が得られていない場合は、認証ダイアログを表示.
            self.myLocationManager.requestAlwaysAuthorization();
        }
        
        // 位置情報の更新を開始.
        myLocationManager.startUpdatingLocation()
        
        // MapViewの生成.
        myMapView = MKMapView()
        
        // MapViewのサイズを画面全体に.
        myMapView.frame = self.view.bounds
        
        // Delegateを設定.
        myMapView.delegate = self
        
        // MapViewをViewに追加.
        self.view.addSubview(myMapView)
        
        
        // Regionを作成.
        let myRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(targetLocation.coordinate, myLatDist, myLonDist);
        
        // MapViewに反映.
        myMapView.setRegion(myRegion, animated: true)
        
        setPinWithCircle(targetLocation, circleDistance: pinDistance)
 

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // GPSから値を取得した際に呼び出されるメソッド.
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        // 配列から現在座標を取得.
        var myLocations: NSArray = locations as NSArray
        var myLastLocation: CLLocation = myLocations.lastObject as! CLLocation
        var myLocation:CLLocationCoordinate2D = myLastLocation.coordinate
        
        
        // Regionを作成.
        let myRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(myLocation, myLatDist, myLonDist);
        
        // MapViewに反映.
        myMapView.setRegion(myRegion, animated: true)
        dump(myLocation)
        if existInTheArea(targetLocation, targetLocationDistance: pinDistance, existLocation: myLastLocation) {
            println("入ってる")
        } else {
            println("入ってない")
        }
    }
    
    // Regionが変更した時に呼び出されるメソッド.
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        println("regionDidChangeAnimated")
    }
    
    // 認証が変更された時に呼び出されるメソッド.
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status{
        case .AuthorizedWhenInUse:
            println("AuthorizedWhenInUse")
        case .Denied:
            println("Denied")
        case .Restricted:
            println("Restricted")
        case .NotDetermined:
            println("NotDetermined")
        default:
            println("etc.")
        }
    }
    
    /*
    addOverlayした際に呼ばれるデリゲートメソッド.
    */
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        // rendererを生成.
        let myCircleView: MKCircleRenderer = MKCircleRenderer(overlay: overlay)
        
        // 円の内部を赤色で塗りつぶす.
        myCircleView.fillColor = UIColor.redColor()
        
        // 円周の線の色を黒色に設定.
        myCircleView.strokeColor = UIColor.blackColor()
        
        // 円を透過させる.
        myCircleView.alpha = 0.5
        
        // 円周の線の太さ.
        myCircleView.lineWidth = 1.5
        
        return myCircleView
    }
    
    func setPinWithCircle(centerLocation: CLLocation, circleDistance: CLLocationDistance){
        /*ピンを生成*/
        
        // ピンを生成.
        var myPin: MKPointAnnotation = MKPointAnnotation()
        
        // 座標を設定.
        myPin.coordinate = centerLocation.coordinate
        
        // タイトルを設定.
        myPin.title = "テスト"
        
        // サブタイトルを設定.
        myPin.subtitle = "ピンを置くよ"
        
        /* 円を描写 */
        let myCircle: MKCircle = MKCircle(centerCoordinate: centerLocation.coordinate, radius: circleDistance)
        
        // MapViewにピンを追加.
        myMapView.addAnnotation(myPin)
        myMapView.addOverlay(myCircle)
    }
    
    func existInTheArea(targetLocation: CLLocation, targetLocationDistance: CLLocationDistance, existLocation: CLLocation) -> Bool {
        var distance = targetLocation.distanceFromLocation(existLocation) as CLLocationDistance
        println(distance)
        if distance < targetLocationDistance {
            return true
        }
        return false
    }


}
