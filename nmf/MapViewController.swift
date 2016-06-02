//
//  MapViewController.swift
//  nmf
//
//  Created by Ben Lachman on 5/29/16.
//  Copyright © 2016 Nelsonville Music Festival. All rights reserved.
//

import UIKit
import Contacts


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
        let region = MKCoordinateRegionMakeWithDistance(nmf.coordinate, 275.0, 275.0)
        
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
    
    static var once: dispatch_once_t = 0
    
    override func viewDidAppear(animated: Bool) {        
        dispatch_once(&MapViewController.once) {
            self.toggleLegendAction(self)
        }
    }
    
    // MARK: - Actions
    
    @IBOutlet weak var lengendTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var legendImageView: UIImageView!
    
    @IBAction func toggleLegendAction(sender: AnyObject) {
        var height = -(legendImageView.bounds.height)
        var delay = 0.0
        
        if sender is MapViewController {
            delay = 0.33
        } else if lengendTopConstraint.constant < 0 {
            height = self.mapView.frame.height + height
        }
        
        self.lengendTopConstraint.constant = height

        UIView.animateWithDuration(0.4, delay: delay, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.25, options: [], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    
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
        let alertController = UIAlertController(title: "Need Directions to NMF?", message: nil, preferredStyle: .ActionSheet)
        
         alertController.addAction(UIAlertAction(title: "Open in Maps", style: .Default, handler: { (action) in
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: self.nmf.coordinate, addressDictionary: [CNPostalAddressCityKey: "Nelsonville", CNPostalAddressStateKey: "Ohio"]))
            
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            
            mapItem.openInMapsWithLaunchOptions(launchOptions)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
         presentViewController(alertController, animated: true, completion: nil)
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