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
    
    var editMode = false
    
    var selectedCellIndexes = [NSIndexPath]()
    var deletedCellIndexes = [NSIndexPath]()
    var insertedCellIndexes = [NSIndexPath]()
    var updatedCellIndexes = [NSIndexPath]()
    
    
    
    @IBOutlet weak var noImageLabel: UILabel!
    
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
        actionButton.enabled = false
        noImageLabel.hidden = true
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        flowLayoutControl.minimumInteritemSpacing = space
        flowLayoutControl.itemSize = CGSizeMake(dimension, dimension)
        
        collView.delegate = self
        collView.dataSource = self
        
        fetchedResultsController.delegate = self
        fetchData()
        if (fetchedResultsController.fetchedObjects?.count == 0) {
            print("no images")
            noImageLabel.hidden = false
        }
        else {
            noImageLabel.hidden = true
            actionButton.enabled = true
        }
        
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
        else {
            
            //delete pics
            actionButton.enabled = false
            for photo in fetchedResultsController.fetchedObjects as! [Photo]{
                sharedDataInstance.context.deleteObject(photo)
            }
            performUIUpdatesOnMain {
                self.flickrClient.getImages(self.location, context: self.sharedDataInstance.context) {
                    (results, error) in
                    if error != nil {
                        print(error)
                    } else {
                        self.sharedDataInstance.save()
                    }
                }
            }
            self.fetchData()
            self.collView.reloadData()
        }
    }
    
    
    //MARK: - Collection View Data Source methods
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let sectionInfo = self.fetchedResultsController.sections![section]
        
        return sectionInfo.numberOfObjects
        
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
            cell.activityIndicator.stopAnimating()
        }
        else {
            cell.layer.cornerRadius = 5
            cell.backgroundColor = UIColor.lightGrayColor()
            cell.activityIndicator.startAnimating()
            cell.imageView.image = nil
        }
        return cell
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
            case .Insert:
                collView.insertSections(NSIndexSet(index: sectionIndex))
            case .Delete:
                collView.deleteSections(NSIndexSet(index: sectionIndex))
            default:
                return
        }
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            
            
            switch type {
                case .Insert:
                    insertedCellIndexes.append(newIndexPath!)
                case .Delete:
                    deletedCellIndexes.append(indexPath!)
                case .Move:
                    collView.deleteItemsAtIndexPaths([indexPath!])
                    collView.insertItemsAtIndexPaths([newIndexPath!])
            case .Update:
                updatedCellIndexes.append(indexPath!)
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        //Reset the arrays that track the indexPaths to handle the changes in content
        deletedCellIndexes.removeAll()
        insertedCellIndexes.removeAll()
        updatedCellIndexes.removeAll()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if controller.fetchedObjects?.count > 0 {
            actionButton.enabled = true
        }
        collView.performBatchUpdates({ () -> Void in
            for indexPath in self.insertedCellIndexes {
                self.collView.insertItemsAtIndexPaths([indexPath])
            }
            for indexPath in self.deletedCellIndexes {
                self.collView.deleteItemsAtIndexPaths([indexPath])
            }
            for indexPath in self.updatedCellIndexes {
                self.collView.reloadItemsAtIndexPaths([indexPath])
            }
        }, completion: nil)
    }
    

}