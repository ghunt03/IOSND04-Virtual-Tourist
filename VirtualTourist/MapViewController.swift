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
    @IBOutlet weak var editButton: UIBarButtonItem!
    var removeMode: Bool = false
    var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setPersistedMapLocation()
        loadLocations()
        createLabel()
        
        
    }
    
    func createLabel(){
        let x = self.view.frame.origin.x
        let y = self.view.frame.origin.y + view.frame.height - 40
        let rect = CGRect(x: x, y: y, width: view.frame.width, height: 40)
        label = UILabel(frame: rect)
        label!.center = CGPointMake(view.frame.width/2, view.frame.height-20)
        label!.text = "Tap pins to delete"
        label!.textAlignment = .Center
        label!.textColor = UIColor.whiteColor()
        label!.backgroundColor = UIColor.redColor()
    }
    
    @IBAction func editButtonPressed(sender: AnyObject) {
        if removeMode {
            removeMode = false
            editButton.title = "Edit"
            //hide label
            view.frame.origin.y += 40
            label!.removeFromSuperview()
        }
        else {
            removeMode = true
            editButton.title = "Done"
            //show label
            view.frame.origin.y -= 40
            view.superview?.addSubview(label!)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
        let fr = NSFetchRequest(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        // Create the FetchedResultsController
        let fc = NSFetchedResultsController(fetchRequest: fr,
            managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        do{
            try fc.performFetch()
        }catch let e as NSError{
            print("Error while trying to perform a search: \n\(e)\n\(fc)")
        }
        let locations = fc.fetchedObjects as! [Pin]
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
            let newLocation = Pin(latitude: Double(newCoord.latitude),
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
                locationVC.location = (sender as! Pin)
            }
        }
    }
    
    
    func getLocationByCoordinates(latitude: Double, longitude: Double) -> Pin? {
        let fr = NSFetchRequest(entityName: "Pin")
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
        let locations = fc.fetchedObjects as! [Pin]
        return locations[0]
        
    }
    
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let coords = view.annotation?.coordinate
        let pin = getLocationByCoordinates((coords?.latitude)!, longitude: (coords?.longitude)!)
        if (removeMode) {
            mapView.removeAnnotation(view.annotation!)
            sharedContext.deleteObject(pin!)
        }
        else {
            performSegueWithIdentifier("displayLocation", sender: pin)
        }
    }
    
    
    
}