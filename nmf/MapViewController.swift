//
//  MapViewController.swift
//  nmf
//
//  Created by Ben Lachman on 5/29/16.
//  Copyright © 2016 Nelsonville Music Festival. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, MKMapViewDelegate {
    let athens = CLLocation(latitude: 39.329288, longitude: -82.100510)

    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        // 2.17 miles = 3500 meters
        let region = MKCoordinateRegionMakeWithDistance(athens.coordinate, 3500.0, 3500.0)
        
        mapView.setRegion(region, animated: true)
    }
    
//    override func viewWillAppear(animated: Bool) {
//        let UIApplication.sharedApplication().delegate
//            .requestWhenInUseAuthorization()
//        
//        super.viewWillAppear(animated)
//    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch (status) {
        case .AuthorizedWhenInUse:
            print("authed")
        default:
            print("shit.")
        }
    }
}
