//
//  CollectionViewController.swift
//  VirtualTourist
//
//  Created by Gareth Hunt on 9/06/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class CollectionViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var mkView: MKAnnotationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMapLocation()
    }
    
    func setMapLocation() {
        if (mkView != nil) {
            let newCoord = mkView?.annotation?.coordinate
            
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: newCoord!, span: span)
            let newAnotation = MKPointAnnotation()
            newAnotation.coordinate = newCoord!
            mapView.addAnnotation(newAnotation)

            mapView.setRegion(region, animated: true)
        }
    }
    
    
}