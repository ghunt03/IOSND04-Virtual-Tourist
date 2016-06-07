//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Gareth Hunt on 7/06/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setPersistedMapLocation()
    }
    
    func setPersistedMapLocation() {
        let latitudeDelta = NSUserDefaults.standardUserDefaults().doubleForKey(MapViewConstants.Constants.latDelta)
        let longitudeDelta = NSUserDefaults.standardUserDefaults().doubleForKey(MapViewConstants.Constants.longDelta)
        let latitude = NSUserDefaults.standardUserDefaults().doubleForKey(MapViewConstants.Constants.lat)
        let longitude = NSUserDefaults.standardUserDefaults().doubleForKey(MapViewConstants.Constants.long)
        let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapView.centerCoordinate
        let regionSpan = mapView.region.span
        NSUserDefaults.standardUserDefaults().setDouble(center.latitude, forKey: MapViewConstants.Constants.lat)
        NSUserDefaults.standardUserDefaults().setDouble(center.longitude, forKey: MapViewConstants.Constants.long)
        NSUserDefaults.standardUserDefaults().setDouble(regionSpan.latitudeDelta, forKey: MapViewConstants.Constants.latDelta)
        NSUserDefaults.standardUserDefaults().setDouble(regionSpan.longitudeDelta, forKey: MapViewConstants.Constants.longDelta)
    }
    
    
}