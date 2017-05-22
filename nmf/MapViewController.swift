//
//  MapViewController.swift
//  nmf
//
//  Created by Ben Lachman on 5/29/16.
//  Copyright © 2017 Nelsonville Music Festival. All rights reserved.
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
    let tileOverlay = TileOverlay(urlTemplate: Bundle.main.bundleURL.absoluteString + "mapdata/{z}/{x}/{y}.png")
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var currentLocationButton: UIButton!
    
    
    override func viewDidLoad() {
        // 2.17 miles = 3500 meters
        let region = MKCoordinateRegionMakeWithDistance(nmf.coordinate, 275.0, 275.0)
        
        mapView.setRegion(region, animated: true)
        
        tileOverlay.canReplaceMapContent = false
        mapView.insert(tileOverlay, at: 0, level: .aboveRoads)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // location manager
        
        let authorization = CLLocationManager.authorizationStatus()
        
        if authorization == .denied || authorization == .restricted {
            print("Unabled to access location")
        } else {
            if authorization == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            
            if CLLocationManager.locationServicesEnabled() == true {
                locationManager.startUpdatingLocation()
            }
        }
        
        currentLocationButton.layer.borderColor = UIColor.tanBackground().cgColor
        currentLocationButton.layer.borderWidth = 1
        currentLocationButton.layer.cornerRadius = 12
        
        
        super.viewWillAppear(animated)
    }
    
    private lazy var setupLegend: Void = {
        self.toggleLegendAction(self)
        // Do this once
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        _ = setupLegend
    }
    
    // MARK: - Actions
    
    @IBOutlet weak var lengendTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var legendImageView: UIImageView!
    
    @IBAction func toggleLegendAction(_ sender: AnyObject) {
        var height = -(legendImageView.bounds.height)
        var delay = 0.0
        
        if sender is MapViewController {
            delay = 0.33
        } else if lengendTopConstraint.constant < 0 {
            height = self.mapView.frame.height + height
        }
        
        self.lengendTopConstraint.constant = height

        UIView.animate(withDuration: 0.4, delay: delay, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.25, options: [], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction func locationButtonAction(_ sender: UIButton) {
        if let userLocation = locationManager.location {
            mapView.setCenter(userLocation.coordinate, animated: true)
        }
    }
    
    @IBAction func nmfButtonAction(_ sender: AnyObject) {
        let region = MKCoordinateRegionMakeWithDistance(nmf.coordinate, 300.0, 300.0)
        
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func actionButtonAction(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Need Directions to NMF?", message: nil, preferredStyle: .actionSheet)
        
         alertController.addAction(UIAlertAction(title: "Open in Maps", style: .default, handler: { (action) in
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: self.nmf.coordinate, addressDictionary: [CNPostalAddressCityKey: "Nelsonville", CNPostalAddressStateKey: "Ohio"]))
            
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            
            mapItem.openInMaps(launchOptions: launchOptions)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        
         present(alertController, animated: true, completion: nil)
    }
    
    
    
    // MARK: - MapKit delegate methods
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return MKTileOverlayRenderer(tileOverlay: self.tileOverlay)
    }
    
    // MARK: - CLLocationManagerDelegate
    
    //	func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    //	}
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

class TileOverlay : MKTileOverlay {
    // FIXME?
    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        super.loadTile(at: path, result: result)
    }
}
