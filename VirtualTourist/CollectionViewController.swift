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
import CoreData

class CollectionViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var mapView: MKMapView!
    var location: Pin!
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let flickrClient = FlickrClient.sharedInstance
    
    @IBOutlet weak var collView: UICollectionView!
    @IBOutlet weak var flowLayoutControl: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setMapLocation()
        
        
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayoutControl.minimumInteritemSpacing = space
        flowLayoutControl.itemSize = CGSizeMake(dimension, dimension)

        
        collView.delegate = self
        collView.dataSource = self
        
        do {
            try fetchedResultsController.performFetch()
        }catch(let error){
            print(error)
        }
        fetchedResultsController.delegate = self
        if fetchedResultsController.fetchedObjects?.count == 0 {
            flickrClient.getImages(location) {
                (results, error) in
                if error == nil {
                    for photoDictionary in results as! [[String: AnyObject]]{
                        self.flickrClient.getImageFromURL(photoDictionary["url_m"] as! String) {
                            (imageData, error) in
                            if (error == nil) {
                                let p = Photo(id: photoDictionary["id"] as! String,
                                    photoURL: photoDictionary["url_m"] as! String,
                                    title: photoDictionary["title"] as! String,
                                    photoData: imageData as! NSData,
                                    context: self.sharedContext)
                                p.pin = self.location
                                print(imageData)
                            }
                        }
                        
                                            }
                }
                else {
                    print(error)
                }
            }

        }
        
    }
    
    func setMapLocation() {
        if (location != nil) {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: Double(location.latitude!), longitude: Double(location.longitude!))
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
            mapView.addAnnotation(annotation)
        }
        
    }
    
    var sharedContext: NSManagedObjectContext {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return delegate.stack.context
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.location)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "url", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    //COLLECTION VIEW METHODS
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.fetchedResultsController.sections![section].numberOfObjects
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        
        
        
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionViewCell", forIndexPath: indexPath) as! ImageCollectionCell
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        cell.layer.cornerRadius = 5
        cell.backgroundColor = UIColor.lightGrayColor()
        cell.activityIndicator.startAnimating()
        
        if (photo.photoData != nil) {
            let image = UIImage(data: photo.photoData!)
            print(photo)
            print(image)
            cell.imageView.image = image
        }

        return cell
    }

}