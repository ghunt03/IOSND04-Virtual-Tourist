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
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setPersistedMapLocation()
        loadLocations()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "dropPin:")
        longPress.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(longPress)
        
    }
    
    var sharedContext: NSManagedObjectContext {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return delegate.stack.context
    }
    
    func loadLocations() {
        // Invoke fetchedResultsController.performFetch(nil) here
        // Create the fetch request
        let fr = NSFetchRequest(entityName: "Location")
        fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        // Create the FetchedResultsController
        let fc = NSFetchedResultsController(fetchRequest: fr,
            managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        do{
            try fc.performFetch()
        }catch let e as NSError{
            print("Error while trying to perform a search: \n\(e)\n\(fc)")
        }
        let locations = fc.fetchedObjects as! [Location]
        for location in locations {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: Double(location.latitude!), longitude: Double(location.longitude!))
            mapView.addAnnotation(annotation)
        }
    }
    
    func dropPin(gestureRecognizer:UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.locationInView(self.mapView)
        let newCoord:CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
        let newAnotation = MKPointAnnotation()
        newAnotation.coordinate = newCoord
        
        
        if (gestureRecognizer.state == .Ended) {
            mapView.addAnnotation(newAnotation)
            let newLocation = Location(latitude: Double(newCoord.latitude),
                longitude: Double(newCoord.longitude),
                context: self.sharedContext)
            print("Created a new location: \(newLocation)")
        }
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
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "displayLocation") {
            if let locationVC = segue.destinationViewController as? CollectionViewController {
                let coords = (sender as! MKAnnotationView).annotation?.coordinate
                locationVC.location = getLocationByCoordinates((coords?.latitude)!, longitude: (coords?.longitude)!)
            }
        }
    }
    
    
    func getLocationByCoordinates(latitude: Double, longitude: Double) -> Location? {
        let fr = NSFetchRequest(entityName: "Location")
        fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        
        
        let p = NSPredicate(format: "latitude = %@ and longitude = %@", argumentArray: [latitude, longitude])
        fr.predicate = p
        
        // Create the FetchedResultsController
        let fc = NSFetchedResultsController(fetchRequest: fr,
            managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        do{
            try fc.performFetch()
        }catch let e as NSError{
            print("Error while trying to perform a search: \n\(e)\n\(fc)")
        }
        let locations = fc.fetchedObjects as! [Location]
        return locations[0]
        
    }
    
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        performSegueWithIdentifier("displayLocation", sender: view)
    }
    
    
    
}