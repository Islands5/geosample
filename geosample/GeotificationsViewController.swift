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
    
    // 地図の縮尺.(単位メートル)
    let myLatDist : CLLocationDistance = 1000
    let myLonDist : CLLocationDistance = 1000
    
    // 東京タワーの緯度経度35.658581" lon="139.745433
    let targetLocation: CLLocation = CLLocation(latitude: 35.658581, longitude: 139.745433)
    let pinDistance = CLLocationDistance(500)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        myLocationManager.distanceFilter = 100.0
        myLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        // セキュリティ認証
        let status = CLLocationManager.authorizationStatus()
        if(status == CLAuthorizationStatus.NotDetermined) {
            self.myLocationManager.requestAlwaysAuthorization();
        }
        
        //　位置情報の取得をBGで動かす
        myLocationManager.startUpdatingLocation()
        
        myMapView = MKMapView()
        myMapView.frame = self.view.bounds
        myMapView.delegate = self

        self.view.addSubview(myMapView)
        
        let myRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(targetLocation.coordinate, myLatDist, myLonDist);
        myMapView.setRegion(myRegion, animated: true)
        
        setPinWithCircle(targetLocation, circleDistance: pinDistance)
 
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
        var currentCircle: MKCircle = MKCircle(centerCoordinate: myLocation, radius: CLLocationDistance(50))
        myMapView.addOverlay(currentCircle)
        if existInTheArea(targetLocation, targetLocationDistance: pinDistance, existLocation: myLastLocation) {
            println("入ってる")
        } else {
            println("入ってない")
        }
    }
    
    // Regionが変更した時に呼び出されるメソッド.
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
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
        var myPin: MKPointAnnotation = MKPointAnnotation()
        myPin.coordinate = centerLocation.coordinate
        myPin.title = "東京タワー"
        myPin.subtitle = "テストです"
        
        let myCircle: MKCircle = MKCircle(centerCoordinate: centerLocation.coordinate, radius: circleDistance)
        
        myMapView.addAnnotation(myPin)
        myMapView.addOverlay(myCircle)
    }
    
    func existInTheArea(targetLocation: CLLocation, targetLocationDistance: CLLocationDistance, existLocation: CLLocation) -> Bool {
        var distance = targetLocation.distanceFromLocation(existLocation) as CLLocationDistance
        
        if distance < targetLocationDistance {
            return true
        }
        return false
    }


}
