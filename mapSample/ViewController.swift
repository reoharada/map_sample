//
//  ViewController.swift
//  mapSample
//
//  Created by REO HARADA on 2020/02/03.
//  Copyright © 2020 reo harada. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIScrollViewDelegate  {

    // 面積計算URL
    // https://github.com/GEOSwift/GEOSwift
    
    @IBOutlet weak var mapView: MKMapView!
    // GPS
    var manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapView.mapType = .hybridFlyover
        
        // 現在地表示する
        mapView.showsUserLocation = true
        
        // 許可取る
        manager.requestAlwaysAuthorization()
        manager.delegate = self
        mapView.delegate = self
        // 計測移動距離
        manager.distanceFilter = 1.0
        // 計測開始
        manager.startUpdatingLocation()
        let tokyoTower = CLLocationCoordinate2D(latitude: 35.658577, longitude: 139.745451)
        let region = CLCircularRegion(center: tokyoTower, radius: 1000, identifier: "tokyoTower")
        manager.startMonitoring(for: region)
    }
    
    var createdView: UIView!
    override func viewDidAppear(_ animated: Bool) {
        Timer.scheduledTimer(withTimeInterval: 0.0001, repeats: true) { (ti) in
            self.createShape()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mapView.centerCoordinate = manager.location!.coordinate
        mapView.region = MKCoordinateRegion(center: manager.location!.coordinate, latitudinalMeters: 100.0, longitudinalMeters: 100.0)
        print(locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print(region.identifier)
        print("中にいる")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("あとにしました")
    }

    func addPin(_ coordinage: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinage
        annotation.title = "hogehoge"
        mapView.addAnnotation(annotation)
    }
    
    var touchesPos = [CLLocationCoordinate2D]()
    @IBAction func touchMap(_ sender: Any) {
        let gesture = sender as? UITapGestureRecognizer
        let viewPos = gesture?.location(in: self.view)
        let mapPos = self.mapView.convert(viewPos!, toCoordinateFrom: self.mapView)
        print(viewPos)
        print(mapPos)
        addPin(mapPos)
        touchesPos.append(mapPos)
    }
    
    func createShape() {
        if touchesPos.count == 2 {
            if createdView != nil {
                createdView.removeFromSuperview()
            }
            let line = LineView(frame: CGRect(x: 0, y: 0, width: mapView.frame.width, height: mapView.frame.height))
            let startPos = self.mapView.convert(touchesPos[0], toPointTo: mapView)
            let endPos = self.mapView.convert(touchesPos[1], toPointTo: mapView)
            line.start = startPos
            line.end = endPos
            line.backgroundColor = .clear
            line.isUserInteractionEnabled = false
            createdView = line
            mapView.addSubview(createdView)
        }
        if touchesPos.count == 3 {
            if createdView != nil {
                createdView.removeFromSuperview()
            }
            let line = TrriangleView(frame: CGRect(x: 0, y: 0, width: mapView.frame.width, height: mapView.frame.height))
            let startPos = self.mapView.convert(touchesPos[0], toPointTo: mapView)
            let middlePos = self.mapView.convert(touchesPos[1], toPointTo: mapView)
            let endPos = self.mapView.convert(touchesPos[2], toPointTo: mapView)
            line.start = startPos
            line.middle = middlePos
            line.end = endPos
            line.backgroundColor = .clear
            line.isUserInteractionEnabled = false
            createdView = line
            mapView.addSubview(createdView)
        }

    }

    @IBAction func tapButton(_ sender: Any) {
        let location = manager.location!
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (places, error) in
            print(places)
        }
    }
    
}

class LineView: UIView {
    var start = CGPoint(x: 0, y: 0)
    var end = CGPoint(x: 0, y: 0)
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        path.lineWidth = 5.0
        UIColor.brown.setStroke()
        path.stroke()
    }
}

class TrriangleView: UIView {
    var start = CGPoint(x: 0, y: 0)
    var middle = CGPoint(x: 0, y: 0)
    var end = CGPoint(x: 0, y: 0)
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: middle)
        path.addLine(to: end)
        path.addLine(to: start)
        path.lineWidth = 5.0
        UIColor.brown.setStroke()
        path.stroke()
        UIColor(red: 1.0, green: 0.784, blue: 0.306, alpha: 0.5).setFill()
        path.fill()
    }
}
