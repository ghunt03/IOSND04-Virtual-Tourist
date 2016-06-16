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
    var selectedCellIndexes = [NSIndexPath]()
    var editMode = false
    
    @IBOutlet weak var collView: UICollectionView!
    @IBOutlet weak var flowLayoutControl: UICollectionViewFlowLayout!
    
    @IBOutlet weak var actionButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var sharedDataInstance: CoreDataStack {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return delegate.stack
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
        
        fetchedResultsController.delegate = self
        fetchData()
        
    }
    
    
    func fetchData() {
        do {
            try fetchedResultsController.performFetch()
        }catch(let error){
            print(error)
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
    
    @IBAction func actionButtonPressed(sender: AnyObject) {
        if editMode {
            for indexPath in selectedCellIndexes {
                let photoToDelete = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
                sharedDataInstance.context.deleteObject(photoToDelete)
            }
            selectedCellIndexes.removeAll()
            editMode = false
            actionButton.title = "New Collection"
            fetchData()
            collView.reloadData()
        }
    }
    
    //COLLECTION VIEW METHODS
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.fetchedResultsController.sections![section].numberOfObjects
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        let cell = collView.cellForItemAtIndexPath(indexPath)
        if let index = selectedCellIndexes.indexOf(indexPath){
            selectedCellIndexes.removeAtIndex(index)
            cell!.layer.borderWidth = 0

        } else {
            selectedCellIndexes.append(indexPath)
            cell!.layer.borderColor = UIColor.redColor().CGColor
            cell!.layer.borderWidth = 5
        }
        if selectedCellIndexes.count > 0 {
            editMode = true
            actionButton.title = "Remove Selected Images"
        }
        else {
            editMode = false
            actionButton.title = "New Collection"
        }
        

        
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionViewCell", forIndexPath: indexPath) as! ImageCollectionCell
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        if (photo.photoData != nil) {
            let image = UIImage(data: photo.photoData!)
            cell.imageView.image = image
        }
        else {
            cell.layer.cornerRadius = 5
            cell.backgroundColor = UIColor.lightGrayColor()
            cell.activityIndicator.startAnimating()
        }
        return cell
    }

}