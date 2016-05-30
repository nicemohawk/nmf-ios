//
//  MapViewController.swift
//  nmf
//
//  Created by Ben Lachman on 5/29/16.
//  Copyright © 2016 Nelsonville Music Festival. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        return manager
    }()
    
    let nmf = CLLocation(latitude: 39.441032, longitude: -82.218418)
    let tileOverlay = TileOverlay(URLTemplate: NSBundle.mainBundle().bundleURL.absoluteString + "mapdata/{z}/{x}/{y}.png")
    
    @IBOutlet var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        // 2.17 miles = 3500 meters
        let region = MKCoordinateRegionMakeWithDistance(nmf.coordinate, 300.0, 300.0)
        
        mapView.setRegion(region, animated: true)
        
        tileOverlay.canReplaceMapContent = false
        mapView.insertOverlay(tileOverlay, atIndex: 0, level: .AboveRoads)
    }
    
    override func viewWillAppear(animated: Bool) {
        // location manager
        
        let authorization = CLLocationManager.authorizationStatus()
        
        if authorization == .Denied || authorization == .Restricted {
            print("Unabled to access location")
        } else {
            if authorization == .NotDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            
            if CLLocationManager.locationServicesEnabled() == true {
                locationManager.startUpdatingLocation()
            }
        }
        super.viewWillAppear(animated)
    }
    
    // MARK: - Actions
    
    @IBAction func locationButtonAction(sender: UIBarButtonItem) {
        if let userLocation = locationManager.location {
            mapView.setCenterCoordinate(userLocation.coordinate, animated: true)
        }
    }
    
    @IBAction func nmfButtonAction(sender: AnyObject) {
        let region = MKCoordinateRegionMakeWithDistance(nmf.coordinate, 300.0, 300.0)
        
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func actionButtonAction(sender: UIBarButtonItem) {
    }
    
    // MARK: - MapKit delegate methods
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        return MKTileOverlayRenderer(tileOverlay: self.tileOverlay)
    }
    
    // MARK: - CLLocationManagerDelegate
    
    //	func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    //	}
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.localizedDescription)
    }
}

class TileOverlay : MKTileOverlay {
    override func loadTileAtPath(path: MKTileOverlayPath, result: (NSData?, NSError?) -> Void) {
        super.loadTileAtPath(path, result: result)
    }
}