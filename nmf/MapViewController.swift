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
    let nmf = CLLocation(latitude: 39.441032, longitude: -82.218418)
    
    let tileOverlay = TileOverlay(URLTemplate: NSBundle.mainBundle().bundleURL.absoluteString + "/mapdata/{z}/{x}/{y}.png")
 
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        // 2.17 miles = 3500 meters
        let region = MKCoordinateRegionMakeWithDistance(nmf.coordinate, 350.0, 350.0)
        
        mapView.setRegion(region, animated: true)
        
        tileOverlay.canReplaceMapContent = false
        mapView.insertOverlay(tileOverlay, atIndex: 0, level: .AboveRoads)
    }
    
//    override func viewWillAppear(animated: Bool) {
//        let UIApplication.sharedApplication().delegate
//            .requestWhenInUseAuthorization()
//        
//        super.viewWillAppear(animated)
//    }
    
    // MARK: map kit delegate methods
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        return MKTileOverlayRenderer(tileOverlay: self.tileOverlay)
    }
}

class TileOverlay : MKTileOverlay {
    override func loadTileAtPath(path: MKTileOverlayPath, result: (NSData?, NSError?) -> Void) {
        super.loadTileAtPath(path, result: result)
    }
}